from collections import defaultdict
import tempfile

import pandas as pd
from django.http.response import FileResponse
from django.views.generic import TemplateView
from django.forms import modelformset_factory
from django.shortcuts import render
from django.urls import reverse
from django.http import HttpResponseRedirect

from core.models.view_tables import (
    ExperimentInstance,
    OutcomeInstance,
    OutcomeTemplate,
    Note,
)
from core.forms.custom_types import OutcomeInstanceForm, UploadFileForm
from core.widgets import ValWidget


class ExperimentOutcomeView(TemplateView):
    template_name = "core/experiment_outcome.html"
    OutcomeFormSet = modelformset_factory(
        OutcomeInstance,
        form=OutcomeInstanceForm,
        extra=0,
        widgets={"actual_value": ValWidget()},
    )

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        pk = kwargs["pk"]
        # experiment = ExperimentInstance.objects.get(pk=pk)
        # context = self.get_outcome_forms(experiment, context)
        # context['outcome_file_url'] = reverse('outcome_file', kwargs={'pk':pk})
        context["outcome_file_upload_form"] = UploadFileForm()
        context["outcome_file_upload_form_helper"] = UploadFileForm.get_helper()
        context["outcome_file_upload_form_helper"].form_tag = False
        return render(request, self.template_name, context)

    def get_outcome_forms(self, experiment, context):
        outcome_instances = (
            experiment.outcome_instance_experiment_instance.all().order_by(
                "description"
            )
        )

        outcome_formset = self.OutcomeFormSet(queryset=outcome_instances)
        context["outcome_formset"] = outcome_formset
        context["helper"] = OutcomeInstanceForm.get_helper()
        context["helper"].form_tag = False
        return context

    def post(self, request, *args, **kwargs):
        # context = self.get_context_data(**kwargs)
        # experiment_instance_uuid = request.resolver_match.kwargs['pk']
        # outcome_formset = self.OutcomeFormSet(request.POST)
        # if outcome_formset.is_valid():
        #   outcome_formset.save()
        if "outcome_download" in request.POST:
            return self.download_outcome_file(kwargs["pk"])
        if "outcome_upload" in request.POST:
            df = pd.read_csv(request.FILES["file"])
            self.process_outcome_csv(df, kwargs["pk"])

        if "outcome_formset" in request.POST:
            outcome_formset = self.OutcomeFormSet(request.POST)
            if outcome_formset.is_valid():
                outcome_formset.save()
        return HttpResponseRedirect(reverse("experiment_instance_list"))

    def process_outcome_csv(self, df, exp_uuid):
        outcomes = OutcomeInstance.objects.filter(experiment_instance__uuid=exp_uuid)
        # outcome_templates = OutcomeTemplate.objects.filter(outcome_instance_ot__experiment_instance__uuid=exp_uuid).distinct()
        outcome_templates = ExperimentInstance.objects.get(
            uuid=exp_uuid
        ).parent.outcome_templates.all()
        df.fillna("", inplace=True)
        for ot in outcome_templates:
            # Check if the outcome column exists in dataframe
            if ot.description in df.columns:
                # Loop through each location
                for i, row in df.iterrows():
                    o = outcomes.get(description=row[ot.description + " location"])
                    o.actual_value.value = row[ot.description]
                    # o.actual_value.unit = 'test'
                    o.actual_value.unit = row[ot.description + " unit"]
                    # Placeholder for when all files are uploaded
                    # o.file = file in post data
                    Note.objects.create(
                        notetext=row[ot.description + " notes"], ref_note_uuid=o.uuid
                    )
                    o.save()

    def download_outcome_file(self, exp_uuid):
        # Getting outcomes and its templates
        outcomes = OutcomeInstance.objects.filter(experiment_instance__uuid=exp_uuid)
        outcome_templates = OutcomeTemplate.objects.filter(
            outcome_instance_ot__experiment_instance__uuid=exp_uuid
        ).distinct()

        # Constructing a dictionary for pandas table
        data = defaultdict(list)
        # Loop through each outcome type (for eg. Crystal scores, temperatures, etc)
        for ot in outcome_templates:
            # Loop through each outcome for that type (eg. Crystal score for A1, A2, ...)
            for o in outcomes.filter(outcome_template=ot):
                # Outcome description
                data[ot.description + " location"].append(o.description)
                # Add value of outcome
                data[ot.description].append(o.actual_value.value)
                # Add unit of outcome
                data[ot.description + " unit"].append(o.actual_value.unit)
                # Add filename of outcome (This can be used to associate any file uploaded with the well)
                data[ot.description + " filename"].append("")
                # Extra notes the user may wish to add
                data[ot.description + " notes"].append("")
        df = pd.DataFrame.from_dict(data)
        temp = tempfile.NamedTemporaryFile()
        df.to_csv(temp, index=False)
        temp.seek(0)
        response = FileResponse(
            temp, as_attachment=True, filename=f"outcomes_{exp_uuid}.csv"
        )
        return response
