from __future__ import annotations
from typing import Any
import pytest

from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse
from core.models import ExperimentTemplate

create_experiment_form_data = {
    "exp_name": "asdfsadf",
    "reagent_0-TOTAL_FORMS": "1",
    "reagent_0-INITIAL_FORMS": "1",
    "reagent_0-MIN_NUM_FORMS": "0",
    "reagent_0-MAX_NUM_FORMS": "1000",
    "reagent_0-0-chemical": "e8006099-5d33-4658-98f6-78976a346d1f",
    "reagent_0-0-desired_concentration_0": "0.0",
    "reagent_0-0-desired_concentration_1": "M",
    "reagent_0-0-desired_concentration_2": "num",
    "reagent_0-0-reagent_template_uuid": "b801e189-01fc-4c2c-8565-efbfa239bdf6",
    "reagent_0-0-material_type": "2ee9e1f1-6ab3-4c14-b162-13423b20527d",
    "reagent_1-TOTAL_FORMS": "3",
    "reagent_1-INITIAL_FORMS": "3",
    "reagent_1-MIN_NUM_FORMS": "0",
    "reagent_1-MAX_NUM_FORMS": "1000",
    "reagent_1-0-chemical": "13599103-e8e7-49b8-9765-c010a4d96b68",
    "reagent_1-0-desired_concentration_0": "1.0",
    "reagent_1-0-desired_concentration_1": "M",
    "reagent_1-0-desired_concentration_2": "num",
    "reagent_1-0-reagent_template_uuid": "ff964c74-2221-4e36-a966-4f8004ccf809",
    "reagent_1-0-material_type": "5972181e-23ea-455c-adbb-a0e558a3f940",
    "reagent_1-1-chemical": "a2ce5d5e-ae9b-46be-900f-98264eec7049",
    "reagent_1-1-desired_concentration_0": "1.0",
    "reagent_1-1-desired_concentration_1": "M",
    "reagent_1-1-desired_concentration_2": "num",
    "reagent_1-1-reagent_template_uuid": "5b157cb7-4417-4d65-9798-9e973e31872d",
    "reagent_1-1-material_type": "2cc67ec6-8266-4026-97b9-907534a107a8",
    "reagent_1-2-chemical": "e8006099-5d33-4658-98f6-78976a346d1f",
    "reagent_1-2-desired_concentration_0": "0.0",
    "reagent_1-2-desired_concentration_1": "M",
    "reagent_1-2-desired_concentration_2": "num",
    "reagent_1-2-reagent_template_uuid": "978c3bd9-056a-400c-9c13-9063668ca570",
    "reagent_1-2-material_type": "2ee9e1f1-6ab3-4c14-b162-13423b20527d",
    "reagent_2-TOTAL_FORMS": "2",
    "reagent_2-INITIAL_FORMS": "2",
    "reagent_2-MIN_NUM_FORMS": "0",
    "reagent_2-MAX_NUM_FORMS": "1000",
    "reagent_2-0-chemical": "a2ce5d5e-ae9b-46be-900f-98264eec7049",
    "reagent_2-0-desired_concentration_0": "1.0",
    "reagent_2-0-desired_concentration_1": "M",
    "reagent_2-0-desired_concentration_2": "num",
    "reagent_2-0-reagent_template_uuid": "59db6441-1366-4c51-a51e-6195592e587d",
    "reagent_2-0-material_type": "2cc67ec6-8266-4026-97b9-907534a107a8",
    "reagent_2-1-chemical": "e8006099-5d33-4658-98f6-78976a346d1f",
    "reagent_2-1-desired_concentration_0": "0.0",
    "reagent_2-1-desired_concentration_1": "M",
    "reagent_2-1-desired_concentration_2": "num",
    "reagent_2-1-reagent_template_uuid": "1b28c897-f8bb-4bf9-8bc0-256fa38f79bc",
    "reagent_2-1-material_type": "2ee9e1f1-6ab3-4c14-b162-13423b20527d",
    "reagent_3-TOTAL_FORMS": "1",
    "reagent_3-INITIAL_FORMS": "1",
    "reagent_3-MIN_NUM_FORMS": "0",
    "reagent_3-MAX_NUM_FORMS": "1000",
    "reagent_3-0-chemical": "99092ec5-736d-42ba-898e-c90647f1f294",
    "reagent_3-0-desired_concentration_0": "1.0",
    "reagent_3-0-desired_concentration_1": "M",
    "reagent_3-0-desired_concentration_2": "num",
    "reagent_3-0-reagent_template_uuid": "cfe0ab9e-449f-4688-964d-959689a02644",
    "reagent_3-0-material_type": "8447b782-07d7-4069-933e-343b93a60527",
    "value": "f07474ae-ac39-45f9-bf27-3459d7053d34",
    "dead_volume-value_0": "4000",
    "dead_volume-value_1": "uL",
    "dead_volume-value_2": "num",
    "dead_volume-uuid": "",
    "reaction_parameter_0-value_0": "1.0",
    "reaction_parameter_0-value_1": "s",
    "reaction_parameter_0-value_2": "num",
    "reaction_parameter_0-uuid": "",
    "reaction_parameter_1-value_0": "1.0",
    "reaction_parameter_1-value_1": "rpm",
    "reaction_parameter_1-value_2": "num",
    "reaction_parameter_1-uuid": "",
    "reaction_parameter_2-value_0": "1.0",
    "reaction_parameter_2-value_1": "C",
    "reaction_parameter_2-value_2": "num",
    "reaction_parameter_2-uuid": "0bb31d55-f0ba-4973-ace2-35b6195d8ef6",
    "reaction_parameter_3-value_0": "1.0",
    "reaction_parameter_3-value_1": "s",
    "reaction_parameter_3-value_2": "num",
    "reaction_parameter_3-uuid": "",
    "reaction_parameter_4-value_0": "1.0",
    "reaction_parameter_4-value_1": "s",
    "reaction_parameter_4-value_2": "num",
    "reaction_parameter_4-uuid": "",
    "reaction_parameter_5-value_0": "1.0",
    "reaction_parameter_5-value_1": "C",
    "reaction_parameter_5-value_2": "num",
    "reaction_parameter_5-uuid": "d93c66fe-eae3-4ca3-a384-01706ef686c9",
    "automated": "1",
    "manual": "1",
}

pytestmark = pytest.mark.django_db
client = Client()


def test_create_exp():
    experiment_template = ExperimentTemplate.objects.get(description="Workflow 1")
    session = client.session
    session["experiment_template_uuid"] = str(experiment_template.uuid)
    session.save()
    response = client.post(
        reverse("create_experiment"), create_experiment_form_data, follow=True
    )
    print(response)
    assert "HX-Trigger" not in response, response["HX-Trigger"]
