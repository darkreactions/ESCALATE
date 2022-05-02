import tempfile

from django.http import Http404, FileResponse

from rest_framework import viewsets
from rest_framework.request import Request
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework_extensions.mixins import NestedViewSetMixin
from rest_framework.response import Response
from rest_framework import status
from rest_framework.reverse import reverse


from .serializers import *
import core.models
from core.models.view_tables import (
    ExperimentTemplate,
)

from core.custom_types import Val

from .utils import rest_viewset_views, perform_create_views
import core.models

from rest_framework.permissions import IsAuthenticatedOrReadOnly
from url_filter.integrations.drf import DjangoFilterBackend

from .rest_docs import rest_docs
from rest_framework_extensions.mixins import NestedViewSetMixin
from rest_framework import viewsets
import rest_api


SUPPORTED_CREATE_WFS = []


def save_actor_on_post(self, serializer):
    """Save the person POSTing as the actor associated with a resource being created

    Use this to overload perform_create on a view.
    """
    p = core.models.Person.objects.get(pk=self.request.user.person.uuid)
    actor = core.models.Actor.objects.get(person=p, organization__isnull=True)
    # serializer.save(actor=actor, actor_description=actor.description)
    serializer.save(actor=actor)


class CustomViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        print(self.request.user.groups.all())  # type: ignore
        serializer.save()


def create_viewset(model_name):
    model = getattr(core.models, model_name)
    modelSerializer = getattr(rest_api.serializers, model_name + "Serializer")  # type: ignore

    methods_list = {
        "queryset": model.objects.all(),
        "serializer_class": modelSerializer,
        "permission_classes": [IsAuthenticatedOrReadOnly],
        "filter_backends": [DjangoFilterBackend],
        "filter_fields": "__all__",
        "__doc__": rest_docs.get(model_name.lower(), ""),
    }
    viewset_classes = [NestedViewSetMixin, CustomViewSet]
    globals()[model_name + "ViewSet"] = type(
        model_name + "ViewSet", tuple(viewset_classes), methods_list
    )

    if model_name in perform_create_views:
        globals()[model_name + "ViewSet"].perform_create = save_actor_on_post


for view_name in rest_viewset_views:
    create_viewset(view_name)

create_viewset("Edocument")

# Download file view
def download_blob(request, uuid):
    edoc = core.models.Edocument.objects.get(uuid=uuid)
    contents = edoc.edocument
    filename = edoc.filename
    testfile = tempfile.TemporaryFile()
    testfile.write(contents)
    testfile.seek(0)
    response = FileResponse(testfile, as_attachment=True, filename=filename)

    # response['Content-Disposition'] = 'attachment; filename=blob.pdf'
    return response


# Viewset typing
ExperimentTemplateViewSet: viewsets.ViewSet
NoteViewSet: viewsets.ViewSet
TagAssignViewSet: viewsets.ViewSet
TagAssignViewSet: viewsets.ViewSet
EdocumentViewSet: viewsets.ViewSet
PropertyViewSet: viewsets.ViewSet
ParameterViewSet: viewsets.ViewSet


class ExperimentCreateViewSet(NestedViewSetMixin, viewsets.ViewSet):
    permission_classes = [IsAuthenticatedOrReadOnly]

    def list(self, request, *args, **kwargs):
        experiment_template_uuid = kwargs["parent_lookup_uuid"]
        experiment_template: ExperimentTemplate = ExperimentTemplate.objects.get(
            uuid=experiment_template_uuid
        )
        vessel_templates = experiment_template.get_vessel_templates()
        reagent_templates = experiment_template.get_reagent_templates()
        action_templates = experiment_template.get_action_templates(
            source_vessel_decomposable=False, dest_vessel_decomposable=False
        )

        vessel_template_data = []
        for vt in vessel_templates:
            vt_data = {
                "vessel_template_description": vt.description,
                "vessel_template": reverse(
                    "vesseltemplate-detail", args=[vt.uuid], request=request
                ),
                "vessel": reverse(
                    "vessel-detail", args=[vt.default_vessel.uuid], request=request
                ),
            }
            vessel_template_data.append(vt_data)
        experiment_details = {
            "experiment_name": "",
            "vessel_templates": vessel_template_data,
        }
        serializer = ExperimentTemplateCreateSerializer(experiment_details)
        data = serializer.data
        return Response(data)

    def create(self, request: Request, *args, **kwargs):
        template_uuid = kwargs["parent_lookup_uuid"]
        exp_template = ExperimentTemplate.objects.get(pk=template_uuid)
        template_name = exp_template.description
        exp_name = request.data["experiment_name"]  # type: ignore
        vessel_templates = request.data["vessel_templates"]  # type: ignore
        vt_serializer = VesselTemplateCreateSerializer(data=vessel_templates, many=True)
        request.user
        if vt_serializer.is_valid():
            request.ses


# class ExperimentCreateViewSet(NestedViewSetMixin, viewsets.ViewSet):
#     permission_classes = [IsAuthenticatedOrReadOnly]

#     def list(self, request, *args, **kwargs):
#         q1 = get_action_parameter_querysets(kwargs["parent_lookup_uuid"])
#         q1_mat = get_material_querysets(kwargs["parent_lookup_uuid"])

#         exp_params1 = [
#             {
#                 "nominal_value": row.parameter_value,
#                 "actual_value": row.parameter_value,
#                 "object_description": f"{row.object_description}",
#                 "parameter_def_description": f"{row.parameter_def_description}",
#             }
#             for row in q1
#         ]
#         results = {"experiment_parameters_1": exp_params1}
#         mat_params = [
#             {
#                 "material_name": row.object_description,
#                 "value": request.build_absolute_uri(
#                     reverse(
#                         "inventorymaterial-detail", args=[row.inventory_material.uuid]
#                     )
#                 ),
#             }
#             for row in q1_mat
#         ]

#         results.update({"material_parameters": mat_params, "experiment_name": ""})
#         serializer = ExperimentDetailSerializer(results)

#         return Response(serializer.data)

#     def save_material_params(self, queryset, data):
#         for entry in data:
#             object_desc = entry["material_name"]
#             query = queryset.get(object_description=object_desc)
#             uuid = entry["value"].split("/")[-2]
#             print(uuid)

#             query.inventory_material = InventoryMaterial.objects.get(pk=uuid)
#             query.save()

#     def save_params(self, queryset, data, fields):
#         for entry in data:
#             object_desc = entry["object_description"]
#             param_def_desc = entry["parameter_def_description"]
#             query = queryset.get(
#                 object_description=object_desc, parameter_def_description=param_def_desc
#             )

#             if fields is None:
#                 update_dispense_action_set(query, entry["value"])
#             else:
#                 for db_field, form_field in fields.items():
#                     setattr(query, db_field, entry[form_field])
#                     query.save()

#     def create(self, request, *args, **kwargs):
#         template_uuid = kwargs["parent_lookup_uuid"]

#         exp_template = ExperimentTemplate.objects.get(pk=template_uuid)
#         template_name = exp_template.description

#         exp_name = request.data["experiment_name"]

#         experiment_copy_uuid: uuid.UUID = experiment_copy(template_uuid, exp_name, {})
#         # q1, q2, q3 = get_action_parameter_querysets(experiment_copy_uuid)
#         q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)

#         q1_mat = get_material_querysets(experiment_copy_uuid, template=False)

#         self.save_material_params(q1_mat, request.data["material_parameters"])
#         self.save_params(
#             q1,
#             request.data["experiment_parameters_1"],
#             {
#                 "parameter_val_actual": "actual_value",
#                 "parameter_val_nominal": "nominal_value",
#             },
#         )
#         # self.save_params(q2, request.data['experiment_parameters_2'], None)

#         if template_name in SUPPORTED_CREATE_WFS:
#             if template_name == "liquid_solid_extraction":
#                 lsr_edoc = Edocument.objects.get(
#                     ref_edocument_uuid=exp_template.uuid, title="LSR file"
#                 )
#                 # new_lsr_pk, lsr_msg = liquid_solid_extraction(data, q3, experiment_copy_uuid, lsr_edoc, exp_name)
#                 new_lsr_pk, lsr_msg = liquid_solid_extraction(
#                     data, q1, experiment_copy_uuid, lsr_edoc, exp_name
#                 )
#             elif template_name == "resin_weighing":
#                 lsr_edoc = Edocument.objects.get(
#                     ref_edocument_uuid=exp_template.uuid, title="LSR file"
#                 )
#                 new_lsr_pk, lsr_msg = resin_weighing(
#                     experiment_copy_uuid, lsr_edoc, exp_name
#                 )
#             elif template_name == "perovskite_demo":
#                 # new_lsr_pk, lsr_msg = perovskite_demo(data, q3, experiment_copy_uuid, exp_name)
#                 new_lsr_pk, lsr_msg = perovskite_demo(
#                     data, q1, experiment_copy_uuid, exp_name, exp_template
#                 )

#         return Response(
#             {
#                 "experiment_detail": request.build_absolute_uri(
#                     reverse("experiment-instance-detail", args=[experiment_copy_uuid])
#                 ),
#                 "generated_file": request.build_absolute_uri(
#                     reverse("edoc_download", args=[new_lsr_pk])
#                 ),
#             }
#         )


class SaveViewSet(NestedViewSetMixin, viewsets.ModelViewSet):
    # Override these two variables!
    parent_lookup: str = ""
    ref_uuid: str = ""

    def perform_create(self, serializer, **kwargs):
        serializer.save(**kwargs)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # material = Material.objects.get(uuid=kwargs[self.parent_lookup])
        create_args = {self.ref_uuid: kwargs[self.parent_lookup]}
        self.perform_create(serializer, **create_args)
        headers = self.get_success_headers(serializer.data)
        return Response(
            serializer.data, status=status.HTTP_201_CREATED, headers=headers
        )


save_viewsets = {
    "TagAssignViewSet": {
        "parent_lookup": "parent_lookup_ref_tag",
        "ref_uuid": "ref_tag",
    },
    "NoteViewSet": {
        "parent_lookup": "parent_lookup_ref_note_uuid",
        "ref_uuid": "ref_note_uuid",
    },
    "EdocumentViewSet": {
        "parent_lookup": "parent_lookup_ref_edocument_uuid",
        "ref_uuid": "ref_edocument_uuid",
    },
    "PropertyViewSet": {
        "parent_lookup": "parent_lookup_material",
        "ref_uuid": "material",
    },
    "ParameterViewSet": {
        "parent_lookup": "parent_lookup_ref_object",
        "ref_uuid": "action",
    },
}

for viewset_name, kwargs in save_viewsets.items():
    viewset = globals()[viewset_name]
    globals()[viewset_name] = type(viewset_name, (viewset, SaveViewSet), kwargs)
