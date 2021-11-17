from core.models.view_tables import BomMaterial

details = {
    "BillOfMaterials": {
        "columns": {
            "bom_material": {
                "model_name": "BomMaterial",
                "kwargs": {
                    "source": "bom_material_bom",
                    "many": True,
                    "read_only": True,
                },
            }
        }
    },
    "Workflow": {
        "columns": {
            "step": {
                "model_name": "WorkflowStep",
                "kwargs": {
                    "source": "workflow_step_workflow",
                    "many": True,
                    "read_only": True,
                },
            }
        }
    },
    "ExperimentWorkflow": {
        "columns": {"workflow": {"model_name": "Workflow", "kwargs": {}}}
    },
    "Experiment": {
        "columns": {
            "bill_of_materials": {
                "model_name": "BillOfMaterials",
                "kwargs": {"source": "bom_experiment", "many": True, "read_only": True},
            },
            "workflow": {
                "model_name": "ExperimentWorkflow",
                "kwargs": {
                    "source": "experiment_workflow_experiment",
                    "many": True,
                    "read_only": True,
                },
            },
        }
    },
}

"""
for model_name in details:
    meta_class = type('Meta', (), {'model': getattr(core.models, model_name),
                                   'fields': '__all__'})
    variables = {'Meta': meta_class, }
    columns = details[model_name].get('columns', {})
    for col_name, related_model in columns.items():
        related_model_name = related_model['model_name']
        kwargs = related_model['kwargs']
        related_model_serializer = globals()[related_model_name+'Serializer']

        variables[col_name] = related_model_serializer(**kwargs)

    for var, val in details[model_name].items():
        if var != 'columns':
            variables[var] = val
    globals()[model_name+'Serializer'] = type(model_name+'Serializer',
                                              tuple([EdocListSerializer,
                                                     TagListSerializer,
                                                     NoteListSerializer,
                                                     DynamicFieldsModelSerializer]),
                                              variables)
"""


"""
    bom_material = serializers.SerializerMethodField()

    def get_bom_material(self, obj):
        uuid_list = obj.bom_material_bom.filter(
            bom_material_composite__isnull=True).values_list('pk', flat=True)
        url_list = []
        for uuid in uuid_list:
            url_list.append(reverse('bommaterial-detail',
                                    args=[uuid], request=self.context['request']))
        return url_list
"""
