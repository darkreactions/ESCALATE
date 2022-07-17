from typing import Any, Tuple

from crispy_forms.helper import FormHelper
from crispy_forms.layout import Column, Field, Layout, Row
from django.forms import ChoiceField, Form, Select
from plugins.robot.base_robot_plugin import BaseRobotPlugin


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
        none_option: "list[Tuple[Any, str]]" = [
            (None, "No robot file generator selected")
        ]
        self.fields["select_robot_file_generator"].choices = none_option + [
            (robot_plugin.__name__, robot_plugin.name)
            for robot_plugin in BaseRobotPlugin.__subclasses__()
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
