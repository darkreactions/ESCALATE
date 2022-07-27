from django.urls import reverse, reverse_lazy
from django.views.generic.detail import DetailView

from core.models.view_tables import ExperimentInstance, Edocument
from core.utilities.experiment_utils import (
    get_action_parameter_querysets,
    get_material_querysets,
)

from core.models.view_tables import Note, TagAssign, Tag


class ExperimentDetailView(DetailView):
    model = ExperimentInstance
    model_name = "experiment"  # lowercase, snake case. Ex:tag_type or inventory

    template_name = "core/experiment/detail.html"

    detail_fields = None
    detail_fields_need_fields = None

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        exp = context["object"]

        # dict of detail field names to their value
        detail_data = {}

        q1 = get_action_parameter_querysets(exp.uuid)
        mat_q = get_material_querysets(exp.uuid)
        edocs = Edocument.objects.filter(ref_edocument_uuid=exp.uuid)
        detail_data = {row.object_description: row.inventory_material for row in mat_q}
        detail_data.update(
            {
                f"{row.object_description} {row.parameter_def_description}": f"{row.parameter_value}"
                for row in q1
            }
        )
        # detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q2})
        # detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q3})
        link_data = {
            f"{lsr_edoc.title}": self.request.build_absolute_uri(
                reverse("edoc_download", args=[lsr_edoc.pk])
            )
            for lsr_edoc in edocs
        }

        # get notes
        notes_raw = Note.objects.filter(note_x_note__ref_note=exp.pk)
        notes = []
        for note in notes_raw:
            notes.append("-" + note.notetext)
        context["Notes"] = notes

        # get tags
        tags_raw = Tag.objects.filter(
            pk__in=TagAssign.objects.filter(ref_tag=exp.pk).values_list(
                "tag", flat=True
            )
        )
        tags = []
        for tag in tags_raw:
            tags.append(tag.display_text.strip())
        context["tags"] = ", ".join(tags)

        context["title"] = self.model_name.replace("_", " ").capitalize()
        context["update_url"] = reverse_lazy(
            f"{self.model_name}_update", kwargs={"pk": exp.pk}
        )
        context["detail_data"] = detail_data
        context["file_download_links"] = link_data

        return context
