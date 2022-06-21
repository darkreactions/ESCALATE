from __future__ import annotations
from typing import Any
import json
from django.forms import BaseFormSet
from django.db.models.query import QuerySet
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.custom_types import Val
from core.models.view_tables import Parameter


def get_action_parameter_form_data(
    exp_uuid: str, template: bool = True
) -> tuple[list[Any], list[Any]]:
    q1 = get_action_parameter_querysets(exp_uuid, template)
    """
        This happens before copy, in the template. The only way to identify a parameter is 
        through a combination of object_description and parameter_def_description.

        When the form is submitted, a copy is created of the template and we have to search
        for the correct parameters using descriptions because UUIDS are new!

        The reason for making a copy after editing parameters is because we cannot update
        a WorkflowActionSet as of Jan 2021. We can only create a new one
        """

    # create empty lists for initial q1-q3
    initial_q1: list[Any] = []
    """
        using for loop instead of list comprehension to account for arrays
        this will be basis for implementing new array ui
        """
    # q1 initial
    for row in q1:
        data: dict[str, Any] = {
            "value": row.parameter_value,
            "uuid": json.dumps(
                [f"{row.object_description}", f"{row.parameter_def_description}"]
            ),
        }
        if not row.parameter_value.null:
            if "array" in row.parameter_value.val_type.description:
                data["actual_value"] = Val.from_dict(
                    {
                        "type": "array_num",
                        "value": [0] * len(row.parameter_value.value),
                        "unit": row.parameter_value.unit,
                    }
                )
            else:
                data["actual_value"] = Val.from_dict(
                    {"type": "num", "value": 0, "unit": row.parameter_value.unit}
                )

        initial_q1.append(data)
    q1_details = [f"{row.action_unit_description}" for row in q1]

    return initial_q1, q1_details


def save_forms_q1(queries, formset, fields):
    """Saves custom formset into queries

    Args:
        queries ([Queryset]): List of queries into which the forms values are saved
        formset ([Formset]): Formset
        fields (dict): Dictionary to map the column in queryset with field in formset
    """
    for form in formset:
        if form.has_changed() and form.is_valid():
            data = form.cleaned_data
            desc = json.loads(data["uuid"])
            if len(desc) == 2:
                object_desc, param_def_desc = desc
                # param_def_desc = 'None'. What is param_def_desc? Is it a nominal/actual value?
                query = queries.get(
                    object_description=object_desc,
                    parameter_def_description=param_def_desc,
                )
            else:
                query = queries.get(object_description=desc[0])
            parameter = Parameter.objects.get(uuid=query.parameter_uuid)
            for db_field, form_field in fields.items():
                setattr(parameter, db_field, data[form_field])
            parameter.save(update_fields=list(fields.keys()))
