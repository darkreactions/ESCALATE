from enum import Enum
from django.utils.html import format_html


def _(label, content):
    return (
        label + ' <a tabindex="0" role="button" data-toggle="popover" data-html="true"'
        ' data-trigger="hover" data-placement="auto" data-content="'
        + content
        + '"><span class="fa fa-question-circle"></span></a>'
    )


class RTCreateHelp(Enum):
    NUM_MATERIALS = _(
        "Number of Materials",
        "Select the number of chemicals/materials in this reagent",
    )
    PROPERTIES = _(
        "Select Reagent-Level Properties",
        "Select all the properties you would like to capture for each reagent. "
        "For example, you can capture volume and weight of each reagent",
    )


class CreateExperimentHelp(Enum):
    EXPERIMENT_NAME = _("Experiment Name", "Name of the experiment")
