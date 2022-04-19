from __future__ import annotations
from typing import Any
from collections import defaultdict
import tempfile
from django.core.files.uploadedfile import UploadedFile
from django.db.models.query import QuerySet
from django.template.context import Context

import pandas as pd
from django.http.response import FileResponse
from django.views.generic import TemplateView
from django.forms import modelformset_factory
from django.shortcuts import render
from django.urls import reverse
from django.http import HttpResponseRedirect, HttpResponse, HttpRequest

from core.models.view_tables import (
    ExperimentInstance,
    Outcome,
    OutcomeTemplate,
    Note,
    Edocument,
)
from core.forms.custom_types import OutcomeForm, UploadFileForm
from core.widgets import ValWidget
from django.contrib import messages


class ExperimentOutcomeView(TemplateView):
    template_name = "core/experiment_outcome.html"
    OutcomeFormSet = modelformset_factory(
        Outcome,
        form=OutcomeForm,
        extra=0,
        widgets={"actual_value": ValWidget()},
    )

    def get(self, request: HttpRequest, *args, **kwargs):
        context: dict[str, Any] = self.get_context_data(**kwargs)
        # pk = kwargs["pk"]
        context = self.get_outcome_forms(context)
        return render(request, self.template_name, context)

    def get_outcome_forms(self, context: dict[str, Any]) -> dict[str, Any]:
        context["outcome_file_upload_form"] = UploadFileForm()
        context["outcome_file_upload_form_helper"] = UploadFileForm.get_helper()
        context["outcome_file_upload_form_helper"].form_tag = False
        return context

    def post(
        self, request: HttpRequest, *args: str, **kwargs: int
    ) -> HttpResponseRedirect | FileResponse | HttpResponse:
        # context = self.get_context_data(**kwargs)
        # experiment_instance_uuid = request.resolver_match.kwargs['pk']
        # outcome_formset = self.OutcomeFormSet(request.POST)
        # if outcome_formset.is_valid():
        #   outcome_formset.save()
        if "outcome_download" in request.POST:
            return self.download_outcome_file(kwargs["pk"])
        if "outcome_upload" in request.POST:
            outcome_uploads = UploadFileForm(request.POST, request.FILES)
            if outcome_uploads.is_valid():
                df: pd.DataFrame = pd.read_csv(request.FILES.get("file"))
                related_files = request.FILES.getlist("outcome_files")
                outcomes_processed = self.process_outcome_csv(
                    df, related_files, kwargs["pk"], request
                )
            else:
                return self.get(request, *args, **kwargs)
        if outcomes_processed:
            return HttpResponseRedirect(reverse("experiment_instance_list"))
        else:
            return self.get(request, *args, **kwargs)

    def process_outcome_csv(
        self,
        df: pd.DataFrame,
        related_files: list[UploadedFile],
        exp_uuid: str,
        request: HttpRequest,
    ) -> bool:
        outcomes: QuerySet = Outcome.objects.filter(experiment_instance__uuid=exp_uuid)

        outcome_templates = ExperimentInstance.objects.get(
            uuid=exp_uuid
        ).parent.outcome_templates.all()
        df.fillna("", inplace=True)

        related_filenames = [f.name for f in related_files]
        related_files_dict = dict(zip(related_filenames, related_files))

        # First load add data to Outcome models
        outcome_list = []
        for ot in outcome_templates:
            # Check if the outcome column exists in dataframe
            if ot.description in df.columns:
                # Loop through each location
                for i, row in df.iterrows():
                    o = outcomes.get(description=row[ot.description + " location"])
                    outcome_list.append(o)
                    o.actual_value.value = row[ot.description]
                    # o.actual_value.unit = 'test'
                    o.actual_value.unit = row[ot.description + " unit"]
                    # Placeholder for when all files are uploaded
                    # o.file = file in post data
                    Note.objects.create(
                        notetext=row[ot.description + " notes"], ref_note_uuid=o.uuid
                    )
                    try:
                        outcome_filename: str = row[ot.description + " filename"]
                        if outcome_filename:
                            outcome_file = related_files_dict[outcome_filename]
                            Edocument.objects.create(
                                title=outcome_filename,
                                filename=outcome_filename,
                                source="Outcome form upload",
                                edocument=outcome_file,
                            )
                    except KeyError:
                        messages.error(
                            request,
                            f"Error: File {outcome_filename} in outcome csv not found in uploaded files. Please correct and resubmit",
                        )
                        return False
                    except Exception as e:
                        messages.error(request, f"Error: {e}")
                        return False

        # Call save on all outcomes if everything goes well
        map(lambda o: o.save(), outcome_list)
        # o.save()
        return True

    def download_outcome_file(self, exp_uuid):
        # Getting outcomes and its templates
        outcomes = Outcome.objects.filter(experiment_instance__uuid=exp_uuid)
        outcome_templates = OutcomeTemplate.objects.filter(
            outcome_instance_ot__experiment_instance__uuid=exp_uuid
        ).distinct()

        # Constructing a dictionary for pandas table
        data = defaultdict(list)
        # Loop through each outcome type (for eg. Crystal scores, temperatures, etc)
        for ot in outcome_templates:
            # Loop through each outcome for that type (eg. Crystal score for A1, A2, ...)
            for o in outcomes.filter(outcome_template=ot):
                if (
                    "text" in ot.default_value.description
                ):  # omit unit column for text-based outcomes
                    # Outcome description
                    data[ot.description + " location"].append(o.description)
                    # Add value of outcome
                    data[ot.description].append(o.actual_value.value)
                    # Add filename of outcome (This can be used to associate any file uploaded with the well)
                    data[ot.description + " filename"].append("")
                    # Extra notes the user may wish to add
                    data[ot.description + " notes"].append("")
                else:
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
