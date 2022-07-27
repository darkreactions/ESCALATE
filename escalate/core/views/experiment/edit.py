import json
from datetime import datetime, timezone, tzinfo

from core.custom_types import Val
from core.forms.custom_types import NominalActualForm
from core.forms.experiment import GenerateRobotFileForm, QueueStatusForm
from core.forms.forms import UploadFileForm, TagSelectForm
from core.forms.wizard import PostProcessForm
from core.models.view_tables import (
    BomMaterial,
    Edocument,
    ExperimentInstance,
    ExperimentTemplate,
    Tag,
)
from core.models.view_tables.organization import Actor
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.views.experiment import get_action_parameter_form_data, save_forms_q1
from django.db.models import F
from django.forms import ValidationError, formset_factory
from django.http.response import HttpResponse, HttpResponseRedirect
from django.shortcuts import redirect, render
from django.urls import reverse
from django.utils import timezone
from django.views.generic import TemplateView
from plugins.robot import *
from plugins.robot.base_robot_plugin import BaseRobotPlugin


class ExperimentDetailEditView(TemplateView):
    """
    Combination of Material Edit View and Parameter Edit View
    displays q1_material as well as q1-q3 and allows updating form from details page
    """

    template_name = "core/experiment_detail_editor.html"
    list_template = "core/experiment/list.html"
    NominalActualFormSet = formset_factory(NominalActualForm, extra=0)
    # MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)
    EdocFormSet = formset_factory(form=UploadFileForm)

    def get_action_parameter_forms(self, exp_uuid, context, template=True):
        initial_q1, q1_details = get_action_parameter_form_data(
            exp_uuid=exp_uuid, template=template
        )
        # filter out dispense for rp in edit for q1_details and initial_q1
        # need to do both because form uses the length of initial to output details
        # should just update the filter to filter out everything instead
        q1_details[:] = [x for x in q1_details if "dispense " not in x]
        initial_q1[:] = [x for x in initial_q1 if "dispense " not in x["uuid"]]

        context["q1_param_formset"] = self.NominalActualFormSet(
            initial=initial_q1,
            prefix="q1_param",
        )
        context["q1_param_details"] = q1_details.sort()
        return context

    def get_context_data(self, **kwargs):
        # Setup
        context = super().get_context_data(**kwargs)
        # org_id = self.request.session["current_org_id"]
        # lab = Actor.objects.get(organization=org_id, person__isnull=True)
        # self.all_experiments = ExperimentTemplate.objects.filter(lab=lab)
        # context["all_experiments"] = self.all_experiments
        pk = str(kwargs["pk"])
        experiment = ExperimentInstance.objects.get(pk=pk)
        context["experiment"] = experiment
        # parameter redirect
        context["parameter_link"] = reverse(
            "experiment_pending_instance_parameter", args=[experiment.uuid]
        )
        # Queue Status/Priority
        overview_info = [
            ("Queued by", experiment.operator),
            ("Queued on", experiment.add_date),
            ("Template", experiment.template.description),
        ]
        context["overview_info"] = overview_info
        if experiment.metadata is None:
            experiment.metadata = {}
        post_proc_metadata = experiment.metadata.get("post_process", {})
        post_proc_table_data = []
        for date_string, post_proc_name in post_proc_metadata.items():
            timestamp = datetime.fromisoformat(date_string)
            # .replace(
            #    tzinfo=timezone.utc
            # )
            post_proc_table_data.append((timestamp, post_proc_name))
        context["post_process_table_data"] = post_proc_table_data

        # Edocs
        edocs = Edocument.objects.filter(ref_edocument_uuid=experiment.uuid)
        edocs = {
            edoc: (
                # self.request.build_absolute_uri(
                reverse("edoc_download", args=[edoc.pk])
                # )
            )
            for edoc in edocs
        }
        context["edocs"] = edocs
        uf = UploadFileForm()
        context["edoc_upload_form"] = uf
        context["edoc_helper"] = uf.get_helper()
        context["edoc_helper"].form_tag = False
        form_kwargs = {"org_uuid": self.request.session["current_org_id"]}
        qs = QueueStatusForm(experiment)
        context["queue_status_form"] = qs
        context["helper"] = qs.get_helper()
        context["helper"].form_tag = False

        robot_file_gen_form = GenerateRobotFileForm()
        context["robot_file_gen_form"] = robot_file_gen_form

        post_process_form = PostProcessForm(experiment_instance=experiment)
        context["post_process_form"] = post_process_form

        tag_select_form = TagSelectForm(
            model_pk=experiment.uuid,
            queryset=Tag.objects.filter(tag_type__type="experiment"),
        )
        context["tag_select_form"] = tag_select_form

        return context

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        return render(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(*args, **kwargs)
        pk = str(kwargs["pk"])
        exp = ExperimentInstance.objects.get(pk=pk)
        # exp: ExperimentInstance = context["experiment"]
        if request.POST.get("add_edoc"):
            hasfile = "file" in request.FILES.keys()
            if hasfile:
                f = request.FILES.get("file")
                e = Edocument.objects.create(
                    description=f.name,
                    ref_edocument_uuid=exp.uuid,
                    edocument=f.file.read(),
                    filename=f.name,
                    title=f.name,
                    internal_slug=f.name,
                )
                e.save()
                return redirect(request.path)

        if request.POST.get("param_update"):
            if "/experiment_completed_instance/" in request.path:
                return redirect(
                    reverse("experiment_completed_instance_parameter", args=[exp.uuid])
                )
            else:
                return redirect(
                    reverse("experiment_pending_instance_parameter", args=[exp.uuid])
                )

        # save queue status and priority
        qs = QueueStatusForm(exp, request.POST)
        if qs.has_changed():
            if qs.is_valid():
                exp.priority = qs.cleaned_data["select_queue_priority"]
                exp.completion_status = qs.cleaned_data["select_queue_status"]
                exp.save()
                return redirect(request.path)

        robot_file_gen_form = GenerateRobotFileForm(request.POST)
        if robot_file_gen_form.has_changed():
            if robot_file_gen_form.is_valid():
                value = robot_file_gen_form.cleaned_data["select_robot_file_generator"]
                generated, error_message = self.generate_robot_file(value, exp)
                if not generated:
                    robot_file_gen_form.add_error(
                        "select_robot_file_generator",
                        ValidationError(error_message, "error"),
                    )
                    context["robot_file_gen_form"] = robot_file_gen_form
                else:
                    return redirect(request.path)

        post_processor_form = PostProcessForm(request.POST, experiment_instance=exp)
        if post_processor_form.has_changed():
            if not post_processor_form.is_valid():
                context["post_process_form"] = post_processor_form
            else:
                return redirect(request.path)

        tag_select_form = TagSelectForm(
            request.POST,
            model_pk=exp.uuid,
            queryset=Tag.objects.filter(tag_type__type="experiment"),
        )
        if tag_select_form.has_changed():

            if not tag_select_form.is_valid():
                context["tag_select_form"] = tag_select_form
            else:
                tag_select_form.update_tags()
                return redirect(request.path)

        return render(request, self.template_name, context)

    def generate_robot_file(self, class_name: str, exp: ExperimentInstance):
        if class_name in globals():
            RobotFileClass: BaseRobotPlugin = globals()[class_name]
            rfc = RobotFileClass()
            if rfc.validate(exp):
                try:
                    rfc.robot_file(exp)
                    return True, ""
                except Exception as e:
                    return False, str(e)

            else:
                return False, rfc.validation_errors


class ParameterEditView(TemplateView):
    """
    Parameter Edit View
    """

    template_name = "core/parameter.html"
    # list_template = "core/experiment/list.html"
    NominalActualFormSet = formset_factory(NominalActualForm, extra=0)
    # MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)
    # EdocFormSet = formset_factory(form=UploadFileForm)

    def get_action_parameter_forms(self, exp_uuid, context, template=True):
        initial_q1, q1_details = get_action_parameter_form_data(
            exp_uuid=exp_uuid, template=template
        )
        # filter out dispense for rp in edit for q1_details and initial_q1
        # need to do both because form uses the length of initial to output details
        # should just update the filter to filter out everything instead
        # q1_details[:] = [x for x in q1_details if "Dispense " not in x]
        # initial_q1[:] = [x for x in initial_q1 if "Dispense " not in x['uuid']]

        context["q1_param_formset"] = self.NominalActualFormSet(
            initial=initial_q1,
            prefix="q1_param",
        )
        context["q1_param_details"] = q1_details
        return context

    def get_context_data(self, **kwargs):
        # Setup
        context = super().get_context_data(**kwargs)
        related_exp_material = "bom__experiment"
        org_id = self.request.session["current_org_id"]
        lab = Actor.objects.get(organization=org_id, person__isnull=True)
        self.all_experiments = ExperimentTemplate.objects.filter(lab=lab)
        context["all_experiments"] = self.all_experiments
        pk = str(kwargs["pk"])
        experiment = ExperimentInstance.objects.get(pk=pk)
        experiment_field = f'bom__{"experiment_instance" if isinstance(experiment, ExperimentInstance) else "experiment"}'
        context["experiment"] = experiment

        # Queue Status/Priority
        overview_info = [
            ("Queued by", experiment.operator),
            ("Queued on", experiment.add_date),
            ("Template", experiment.template.description),
        ]
        context["overview_info"] = overview_info
        qs = QueueStatusForm(experiment)
        context["queue_status_form"] = qs
        context["helper"] = qs.get_helper()
        context["helper"].form_tag = False

        # Parameters (Nominal/Actual form)
        context = self.get_action_parameter_forms(
            experiment.uuid, context, template=False
        )
        return context

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        return render(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(*args, **kwargs)
        exp = context["experiment"]

        # save queue status and priority
        qs = QueueStatusForm(exp, request.POST)
        if qs.has_changed():
            if qs.is_valid():
                exp.priorty = qs.cleaned_data["select_queue_priority"]
                exp.completion_status = qs.cleaned_data["select_queue_status"]
                exp.save()

        # parameters
        q1 = get_action_parameter_querysets(context["experiment"].uuid, template=False)
        q1_formset = self.NominalActualFormSet(request.POST, prefix="q1_param")
        save_forms_q1(
            q1,
            q1_formset,
            {"parameter_val_nominal": "value", "parameter_val_actual": "actual_value"},
        )
        return render(request, self.template_name, context)
