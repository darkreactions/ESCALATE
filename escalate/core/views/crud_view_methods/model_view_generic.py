import functools
import urllib.parse as urlparse
from typing import Any, Dict, List, Optional, Type

from core.forms.forms import NoteForm, TagSelectForm, UploadEdocForm
from core.models.core_tables import TypeDef, custom_slugify
from core.models.view_tables import (
    Actor,
    Edocument,
    ExperimentInstance,
    Note,
    Tag,
    TagAssign,
)
from core.utilities.utils import camel_to_snake
from core.utils_no_dependencies import (
    get_all_related_fields,
    get_model_of_related_field,
    rgetattr,
)
from django.contrib import messages
from django.core import serializers
from django.core.exceptions import FieldDoesNotExist
from django.db.models import Count, Model, Q
from django.forms import modelformset_factory
from django.http import HttpRequest, HttpResponseRedirect
from django.shortcuts import get_object_or_404, render
from django.urls import reverse, reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import DeleteView
from django.views.generic.list import ListView
from requests import request

from ..exports.export_methods import methods as export_methods
from ..exports.file_types import file_types as export_file_types


class GenericDeleteView(DeleteView):
    def post(self, request, *args, **kwargs):
        if self.model.__name__ in [
            "Property",
            "MaterialIdentifier",
            "ReagentTemplate",
            "VesselTemplate",
            "OutcomeTemplate",
            "Vessel",
        ]:
            self.success_url = request.META["HTTP_REFERER"]
        return super().post(request, *args, **kwargs)


class GenericModelListBase:
    # Override the 2 fields below in subclass
    model: "Type[Model]"
    # lowercase, snake case and plural. Ex:tag_types or inventorys

    # Override 2 fields below in subclass
    table_columns: "list[str]" = []  # list of strings of column names
    # should be a dictionary with keys from table_columns
    column_necessary_fields: "dict[str, list[str]]" = {}
    # and value should be a list of the field names (as strings)needed
    # to fill out the corresponding cell.
    # Fields in list of fields should be spelled exactly
    # Ex: {'Name': ['first_name','middle_name','last_name']}

    # for get_queryset method. Override the 2 fields below in subclass
    ordering = None  # Ex: ['first_name', etc...]
    field_contains: str = ""  # Ex: 'Gary'. Use '' to show all

    # A related path that points to the organization this field belongs to
    org_related_path = None

    default_filter_kwargs = None

    request: HttpRequest

    def header_to_necessary_fields(self, field_raw):
        # get the fields that make up the header column
        return self.column_necessary_fields[field_raw]

    def get_queryset(self):
        filter_val = self.request.GET.get("filter", self.field_contains).strip()

        # Ex: [('first_name_sort', 'asc'),...]
        ui_order_raw = list(
            filter(
                lambda k_v: k_v[0].endswith("_sort")
                and k_v[0].replace("_sort", "") in self.table_columns,
                list(self.request.GET.items()),
            )
        )
        # Ex: {'first_name':'asc'}
        ui_order_dict = {k_v[0].replace("_sort", ""): k_v[1] for k_v in ui_order_raw}

        ui_order = []
        for col_name, order in ui_order_dict.items():
            col_necessary_fields = self.header_to_necessary_fields(col_name)
            # replaces . with __ so django orm can read it
            col_necessary_fields_as_query = [
                "__".join(f.split(".")) for f in col_necessary_fields
            ]
            if order == "asc" or order == None:
                ui_order = [*ui_order, *col_necessary_fields_as_query]
            else:
                # des
                ui_order = [
                    *ui_order,
                    *[f"-{f}" for f in col_necessary_fields_as_query],
                ]

        ordering = ui_order if len(ui_order) > 0 else self.ordering

        _all_necessary_fields_dot = [
            fields[i]
            for fields in self.column_necessary_fields.values()
            for i in range(len(fields))
        ]
        all_necessary_fields_dunder = [
            "__".join(field.split(".")) for field in _all_necessary_fields_dot
        ]
        filter_kwargs = {
            f"{f}__icontains": filter_val for f in all_necessary_fields_dunder
        }

        # Filter by organization if it exists in the model
        if self.request.user.is_superuser:  # type: ignore
            base_query = self.model.objects.all()
        else:
            if "current_org_id" in self.request.session:
                if self.org_related_path:
                    org_filter_kwargs = {
                        f"{self.org_related_path}__uuid": self.request.session[
                            "current_org_id"
                        ]
                    }
                    base_query = self.model.objects.filter(**org_filter_kwargs)
                else:
                    try:
                        org_field = self.model._meta.get_field("organization")
                        base_query = self.model.objects.filter(
                            organization=self.request.session["current_org_id"]
                        )
                    except FieldDoesNotExist:
                        base_query = self.model.objects.all()
            else:
                base_query = self.model.objects.none()

        if self.default_filter_kwargs:
            base_query = base_query.filter(**self.default_filter_kwargs)

        all_related_fields = get_all_related_fields(self.model)
        # filter
        if filter_val != None:
            new_queryset = base_query
            for related_field_query in list(filter_kwargs.keys()):
                related_field = related_field_query.replace("__icontains", "")
                final_field_model = get_model_of_related_field(
                    self.model, related_field, all_related_fields=all_related_fields
                )
                final_field = related_field.split("__")[-1]
                final_field_class_name = final_field_model._meta.get_field(
                    final_field
                ).__class__.__name__
                if final_field_class_name in ["ManyToManyField", "ManyToOneRel"]:
                    filter_kwargs.pop(related_field_query)
                    filter_kwargs[
                        f"{related_field}__internal_slug__icontains"
                    ] = custom_slugify(filter_val)
            filter_query = (
                functools.reduce(
                    lambda q1, q2: q1 | q2,
                    [Q(**{k: v}) for k, v in filter_kwargs.items()],
                )
                if len(filter_kwargs) > 0
                else Q()
            )
            new_queryset = new_queryset.filter(filter_query).distinct()
        else:
            new_queryset = base_query

        # order
        if ordering != None and len(ordering) > 0:
            for i in range(len(ordering)):
                related_field = ordering[i]
                final_field_model = get_model_of_related_field(
                    self.model, related_field, all_related_fields=all_related_fields
                )
                final_field = related_field.split("__")[-1].strip("-")
                final_field_class_name = final_field_model._meta.get_field(
                    final_field
                ).__class__.__name__
                if final_field_class_name == "ManyToManyField":
                    new_queryset = new_queryset.annotate(
                        **{
                            f"{related_field.strip('-')}_count": Count(
                                related_field.strip("-")
                            )
                        }
                    )
                    ordering[i] = f"{related_field}_count"
            new_queryset = new_queryset.order_by(*ordering)

        return new_queryset.select_related()


class GenericModelList(GenericModelListBase, ListView):
    template_name = "core/generic/list.html"
    paginate_by = 10

    @property
    def context_object_name(self) -> Optional[str]:
        if self.model is not None:
            return f"{camel_to_snake(self.model.__name__)}s"

    def get_queryset(self):
        queryset = super().get_queryset()
        if self.context_object_name:
            model_name = self.context_object_name[:-1]
            if self.model.__name__ in export_methods.keys():
                self.request.session[
                    f"{model_name}_queryset_serialized"
                ] = serializers.serialize("json", queryset)
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["table_columns"] = self.table_columns
        if self.context_object_name:
            context["page_obj"].adjusted_elided_pages = context[
                "paginator"
            ].get_elided_page_range(context["page_obj"].number)
            models = context[self.context_object_name]
            model_name = self.context_object_name[:-1]  # Ex: tag_types -> tag_type
            table_data = []
            for model_instance in models:
                table_row_data = []

                # loop to get each column data for one row.
                header_names = self.table_columns
                for field_name in header_names:
                    # get list of fields used to fill out one cell
                    necessary_fields = self.column_necessary_fields[field_name]
                    # get actual field value from the model
                    fields_for_col = []
                    for field in necessary_fields:
                        to_add = rgetattr(model_instance, field)
                        if to_add.__class__.__name__ in [
                            "ManyRelatedManager",
                            "RelatedManager",
                        ]:
                            # if what we get is a many to many object instead of a flat easy to stringify field value
                            # Ex: Model.something.manyToMany
                            to_add = "\n".join([str(x) for x in to_add.all()])  # type: ignore
                        fields_for_col.append(to_add)
                    # loop to change None to '' or non-string to string because join needs strings
                    for k in range(0, len(fields_for_col)):
                        if fields_for_col[k] == None:
                            fields_for_col[k] = ""
                        if not isinstance(fields_for_col[k], str):
                            fields_for_col[k] = str(fields_for_col[k])
                    col_data = " ".join(
                        list(filter(lambda s: len(s) != 0, fields_for_col))
                    )
                    # take away any leading and trailing whitespace
                    col_data = col_data.strip()
                    # change the cell data to be N/A if it is empty string at this point
                    if len(col_data) == 0:
                        col_data = "N/A"
                    table_row_data.append(col_data)

                # dict containing the data, view and update url, primary key and obj
                # name to use in template
                table_row_info = {
                    "table_row_data": table_row_data,
                    "view_url": reverse_lazy(
                        f"{model_name}_view", kwargs={"pk": model_instance.pk}
                    ),
                    "update_url": reverse_lazy(
                        f"{model_name}_update", kwargs={"pk": model_instance.pk}
                    ),
                    "obj_name": str(model_instance),
                    "obj_pk": model_instance.pk,
                }
                if model_name == "edocument":
                    table_row_info["download_url"] = reverse(
                        "edoc_download", args=(model_instance.pk,)
                    )
                # Following links show up to the right of experiment list
                if model_name in (
                    "experiment_instance",
                    "experiment_pending_instance",
                    "experiment_completed_instance",
                ):
                    table_row_info["outcome_url"] = reverse(
                        "outcome", args=(model_instance.pk,)
                    )
                    table_row_info["reagent_prep_url"] = reverse(
                        "reagent_prep", args=(model_instance.pk,)
                    )
                table_data.append(table_row_info)
            context["add_url"] = reverse_lazy(f"{model_name}_add")
            context["table_data"] = table_data
            # get rid of underscores with spaces and capitalize
            context["title"] = model_name.replace("_", " ").capitalize()

            export_urls = {}
            if self.model.__name__ in export_methods.keys():
                _parsed = urlparse.urlparse(self.request.get_full_path())
                query_string = "&".join(
                    [f"{q}={p[0]}" for q, p in urlparse.parse_qs(_parsed.query).items()]
                )
                for file_type in export_file_types:
                    export_urls[file_type] = reverse_lazy(
                        f"{model_name}_export_{file_type}"
                    ) + (f"?{query_string}" if len(query_string) > 0 else "")
                context["export_urls"] = export_urls
        return context

    def post(self, request, *args, **kwargs):
        order_raw = self.request.POST.get("sort", None)
        if self.context_object_name:
            if order_raw:
                col, order = order_raw.split("_")

                # get current query string from path
                parsed = urlparse.urlparse(self.request.get_full_path())
                query = urlparse.parse_qs(parsed.query)

                query_params = {q: p[0] for q, p in query.items()}

                # add clicked column and order to query params
                query_params[f"{col}_sort"] = order

                # build new query string
                new_query_string = "&".join(
                    [f"{q}={p}" for q, p in query_params.items()]
                )

                # add back query params
                new_path = reverse(f"{self.context_object_name[:-1]}_list") + (
                    f"?{new_query_string}" if len(new_query_string) > 0 else ""
                )
                return HttpResponseRedirect(new_path)
            return HttpResponseRedirect(
                reverse(f"{self.context_object_name[:-1]}_list")
            )


class GenericModelEdit:
    template_name = "core/generic/edit_note_tag.html"
    related_uuid = None

    # override in subclass
    model: "Type[Model]"
    form_class = None
    # success_url = reverse_lazy(f'{context_object_name}_list')
    NoteFormSet = modelformset_factory(Note, form=NoteForm, can_delete=True)
    EdocFormSet = modelformset_factory(Edocument, form=UploadEdocForm, can_delete=True)
    request: HttpRequest
    kwargs: Dict[str, Any]

    @property
    def context_object_name(self) -> Optional[str]:
        return camel_to_snake(self.model.__name__) if self.model != None else None

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)  # type: ignore

        if self.context_object_name in context:

            model = context[self.context_object_name]

            note_forms = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=model.pk), prefix="note"
            )

            context["note_forms"] = note_forms

            edocuments = Edocument.objects.filter(ref_edocument_uuid=model.pk)
            edoc_forms = self.EdocFormSet(queryset=edocuments, prefix="edoc")

            context["edoc_forms"] = edoc_forms
            edoc_files = []
            for edoc in edocuments:
                filename = edoc.filename

                # redirect to api link to download
                download_url = reverse("edoc_download", args=(edoc.uuid,))
                edoc_files.append({"filename": filename, "download_url": download_url})
            context["edoc_files"] = edoc_files
            context["edoc_management_form"] = edoc_forms.management_form
            context["tag_select_form"] = TagSelectForm(model_pk=model.pk)
        else:
            context["note_forms"] = self.NoteFormSet(
                queryset=self.model.objects.none(), prefix="note"
            )
            context["edoc_forms"] = self.EdocFormSet(
                queryset=Edocument.objects.none(), prefix="edoc"
            )
            context["edoc_files"] = []
            context["tag_select_form"] = TagSelectForm()

        if isinstance(self.context_object_name, str):
            context["title"] = self.context_object_name.capitalize()

        return context

    def get(self, request, *args, **kwargs):
        self.related_uuid = request.GET.get("related_uuid", None)
        return super().get(request, *args, **kwargs)

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        if self.related_uuid:
            kwargs["related_uuid"] = self.related_uuid
        return kwargs

    def post(self, request, *args, **kwargs):
        if "pk" in self.kwargs:
            model = get_object_or_404(self.model, pk=self.kwargs["pk"])
        else:
            model = self.model()
        if request.POST.get("add_new_tag"):
            request.session["model_name"] = self.context_object_name
            self.success_url = reverse_lazy("model_tag_create", kwargs={"pk": model.pk})
        if request.POST.get("Submit"):
            if self.context_object_name == "outcome":
                self.success_url = reverse(
                    "outcome", kwargs={"pk": model.experiment_instance.uuid}
                )
            elif self.context_object_name == "experiment_template":
                for i in ExperimentInstance.objects.all():
                    if i.template.uuid == self.kwargs["pk"]:
                        messages.error(
                            request,
                            f"Template {model.description} cannot be edited. It has already been used to create experiments",
                        )
                        return HttpResponseRedirect(
                            reverse(f"{self.context_object_name}_list")
                        )
            elif self.model.__name__ in [
                "Property",
                "MaterialIdentifier",
                "ReagentTemplate",
                "VesselTemplate",
                "OutcomeTemplate",
                "Vessel",
            ]:
                self.success_url = request.POST.get("next", self.success_url)
            else:
                self.success_url = reverse(f"{self.context_object_name}_list")
        return super().post(request, *args, **kwargs)  # type: ignore

    def form_valid(self, form):
        print("INSIDE FORM VALID")
        self.object = form.save()

        if self.object.pk is None:
            required_fields = [
                f.name
                for f in self.model._meta.get_fields()
                if not rgetattr(f, "null", False) is True
            ]

            required_fields = [
                f for f in required_fields if f not in ["add_date", "mod_date", "uuid"]
            ]

            query = {
                k: v for k, v in self.object.__dict__.items() if (k in required_fields)
            }

            self.object = self.model.objects.filter(**query).latest("mod_date")

        if self.request.POST.get("tags"):
            # tags from post
            submitted_tags = self.request.POST.getlist("tags")
            # tags from db with a TagAssign that connects the model and the tags
            existing_tags = Tag.objects.filter(
                pk__in=TagAssign.objects.filter(ref_tag=self.object.pk).values_list(
                    "tag", flat=True
                )
            )
            for tag in existing_tags:
                if tag not in submitted_tags:
                    if self.request.user.is_authenticated:
                        # this tag is not assign to this model anymore
                        # delete TagAssign for existing tags that are no longer used
                        TagAssign.objects.filter(tag=tag).delete()
            for tag in submitted_tags:
                # make TagAssign for existing tags that are now used
                if tag not in existing_tags:
                    if self.request.user.is_authenticated:
                        # get actual tag obj with that uuid
                        tag_obj = Tag.objects.get(pk=tag)
                        tag_assign = TagAssign()
                        tag_assign.tag = tag_obj
                        tag_assign.ref_tag = self.object.pk
                        tag_assign.save()
        else:
            # no submitted tags
            # deleted all tags or actually submitted no tags
            existing_tags = Tag.objects.filter(
                pk__in=TagAssign.objects.filter(ref_tag=self.object.pk).values_list(
                    "tag", flat=True
                )
            )
            if self.request.user.is_authenticated:
                for tag in existing_tags:
                    TagAssign.objects.filter(tag=tag).delete()

        if self.NoteFormSet != None:
            actor = Actor.objects.get(
                person=self.request.user.person.pk, organization=None  # type: ignore
            )
            formset = self.NoteFormSet(self.request.POST, prefix="note")
            # Loop through every note form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if self.request.user.is_authenticated:
                        # Get the appropriate actor and then add it to the note
                        note = form.save(commit=False)
                        note.actor = actor
                        # Get the appropriate uuid of the record being changed.
                        note.ref_note_uuid = self.object.pk
                        note.save()

            # Delete each note we marked in the formset
            formset.save(commit=False)
            for form in formset.deleted_forms:
                form.instance.delete()
            # Choose which website we are redirected to
            if self.request.POST.get("add_note"):
                self.success_url = reverse_lazy(
                    f"{self.context_object_name}_update", kwargs={"pk": self.object.pk}
                )

        if self.EdocFormSet != None:
            actor = Actor.objects.get(
                person=self.request.user.person.pk, organization=None  # type: ignore
            )
            formset = self.EdocFormSet(
                self.request.POST, self.request.FILES, prefix="edoc"
            )
            # Loop through every edoc form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if self.request.user.is_authenticated:
                        edoc = form.save(commit=False)
                        if form.cleaned_data["file"]:
                            # New edoc or update file of existing edoc

                            file = form.cleaned_data["file"]
                            # Hopefuly every file name is structed as <name>.<ext>
                            _file_name_detached, ext, *_ = file.name.split(".")

                            edoc.edocument = file.read()
                            edoc.filename = file.name

                            # file type that the user entered
                            file_type_user = form.cleaned_data["file_type"]

                            # try to get the file_type from db that is spelled the same as the file extension
                            try:
                                file_type_db = TypeDef.objects.get(
                                    category="file", description=ext
                                )
                            except TypeDef.DoesNotExist:
                                file_type_db = None

                            if file_type_db:
                                # found find file type corresponding to file extension
                                # use that file type instead of what user entered
                                edoc.doc_type_uuid = file_type_db
                            else:
                                # did not find file type corresponding to file extension
                                # use file type user entered in form

                                # default file type in case file ext is not in db and user did not
                                # enter a file type
                                default_type = TypeDef.objects.get(
                                    category="file", description="text"
                                )

                                edoc.doc_type_uuid = (
                                    file_type_user if file_type_user else default_type
                                )

                        # Get the appropriate actor and then add it to the edoc
                        edoc.actor = actor
                        # Get the appropriate uuid of the record being changed.
                        edoc.ref_edocument_uuid = self.object.pk
                        edoc.save()

            # Delete each note we marked in the formset
            formset.save(commit=False)
            for form in formset.deleted_forms:
                form.instance.delete()
            # Choose which website we are redirected to
            if self.request.POST.get("add_edoc"):
                self.success_url = reverse_lazy(
                    f"{self.context_object_name}_update", kwargs={"pk": self.object.pk}
                )

        return HttpResponseRedirect(self.get_success_url())  # type: ignore

    def form_invalid(self, form):
        print("IN FORM INVALID!")
        context = self.get_context_data()
        context["form"] = form
        return render(self.request, self.template_name, context)


class GenericModelView(DetailView):
    # Override below 2 in subclass
    # model = None
    template_name = "core/generic/detail.html"

    # Override below 2 in subclass
    # list of strings of detail fields (does not need to be same as field names in model)
    detail_fields: List[str]
    detail_fields_need_fields: Dict[
        str, List[str]
    ]  # should be a dictionary with keys detail_fields
    # and value should be a list of the field names (as strings)needed
    # to fill out the corresponding cell.
    # Fields in list of fields should be spelled exactly
    # Ex: {'Name': ['first_name','middle_name','last_name']}

    @property
    def context_object_name(self) -> Optional[str]:
        return camel_to_snake(self.model.__name__) if self.model != None else None

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        assert isinstance(self.context_object_name, str)
        obj = context[self.context_object_name]
        # dict of detail field names to their value
        detail_data = {}

        # loop to get each detail data for one detail field
        for field_verbose in self.detail_fields:
            # get list of fields used to fill out one detail field
            necessary_fields = self.detail_fields_need_fields[field_verbose]
            # get actual field value from the model
            fields_for_field = []
            for field in necessary_fields:
                to_add = rgetattr(obj, field)
                if to_add.__class__.__name__ == "ManyRelatedManager":
                    # if value is many to many obj get the values
                    # Ex: Model.something.manyToMany
                    to_add = "\n".join([str(x) for x in to_add.all()])  # type: ignore
                fields_for_field.append(to_add)
            # loop to change None to '' or non-string to string because join needs strings
            for i in range(0, len(fields_for_field)):
                if fields_for_field[i] == None:
                    fields_for_field[i] = ""
                elif not isinstance(fields_for_field[i], str):
                    fields_for_field[i] = str(fields_for_field[i])
                else:
                    continue
            # concactenate all the fields for field that as not empty strings
            obj_detail = " ".join(list(filter(lambda s: len(s) != 0, fields_for_field)))
            obj_detail = obj_detail.strip()
            if len(obj_detail) == 0:
                obj_detail = "N/A"
            detail_data[field_verbose] = obj_detail

        # get notes
        notes_raw = Note.objects.filter(ref_note_uuid=obj.pk)
        notes = []
        for note in notes_raw:
            notes.append("-" + note.notetext)
        context["Notes"] = notes

        # get tags
        tags_raw = Tag.objects.filter(
            pk__in=TagAssign.objects.filter(ref_tag=obj.pk).values_list(
                "tag", flat=True
            )
        )
        tags = []
        for tag in tags_raw:
            tags.append(tag.display_text.strip())
        context["tags"] = ", ".join(tags)

        # get edocuments
        edocs_raw = Edocument.objects.filter(ref_edocument_uuid=obj.pk)
        edocs = []
        for edoc in edocs_raw:
            filename = edoc.filename

            # redirect to api link to download
            download_url = reverse("edoc_download", args=(edoc.uuid,))
            edocs.append({"filename": filename, "download_url": download_url})
        context["edocs"] = edocs

        context["title"] = self.context_object_name.replace("_", " ").capitalize()
        context["update_url"] = reverse_lazy(
            f"{self.context_object_name}_update", kwargs={"pk": obj.pk}
        )

        # hacky way to additionally add a download button for only for edocument list
        if self.context_object_name == "edocument":
            context["download_url"] = reverse("edoc_download", args=(obj.pk,))
        context["detail_data"] = detail_data
        return context
