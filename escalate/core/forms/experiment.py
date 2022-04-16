from typing import Tuple, Any
from core.widgets import ValWidget, TextInput
from django.forms import (
    Select,
    Form,
    ChoiceField,
)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.widgets import ValFormField
from .forms import dropdown_attrs
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field
from plugins.robot.base_robot_plugin import RobotPlugin


class GenerateRobotFileForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-light",
            "data-live-search": "false",
        }
    )
    select_robot_file_generator = ChoiceField(widget=widget, required=False)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._populate_robot_generator()

    def _populate_robot_generator(self):
        none_option: "list[Tuple[Any, str]]" = [(None, "No preprocessor selected")]
        self.fields["select_robot_file_generator"].choices = none_option + [
            (robot_plugin.__name__, robot_plugin.name)
            for robot_plugin in RobotPlugin.__subclasses__()
        ]


class QueueStatusForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-light",
            "data-live-search": "false",
        }
    )
    select_queue_status = ChoiceField(widget=widget)
    select_queue_priority = ChoiceField(widget=widget)

    def __init__(self, experiment, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["select_queue_status"].choices = [
            ("Pending", "Pending"),
            ("Running", "Running"),
            ("Completed", "Completed"),
        ]
        self.fields["select_queue_status"].initial = experiment.completion_status
        self.fields["select_queue_priority"].choices = [
            ("1", "1"),
            ("2", "2"),
            ("3", "3"),
        ]
        self.fields["select_queue_priority"].initial = experiment.priority

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("select_queue_status"))),
            Row(Column(Field("select_queue_priority"))),
        )
        return helper
