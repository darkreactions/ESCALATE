import re


def camel_case(text):
    #data = re.findall(r'[A-Z](?:[a-z]+|[A-Z]*(?=[A-Z]|$))', text)
    # if data[0] == 'View':
    #    data[0] = 'vw'
    data = text.lower()
    if 'view' in data[:4]:
        data = data[4:]

    # return '_'.join(data).lower()
    return data


def camel_case_uuid(text):
    text = camel_case(text)
    # return '_'.join([text, 'uuid'])
    return text


view_names = ['Systemtool', 'SystemtoolType', 'Actor', 'Inventory', 'InventoryMaterial',
               'Calculation', 'CalculationDef',
              'Material', 'MaterialCalculationJson', 'MaterialRefnameDef',
              'MaterialType', 'Note_x', 'Organization', 'Person',
              'Status', 'TagType', 'PropertyDef', 'MaterialProperty', 'TypeDef',
              'ParameterDef', 'Condition', 'ConditionDef', 'Parameter', 'WorkflowType',
              'WorkflowStep', 'WorkflowObject']

GET_only_views = ['TypeDef']

custom_serializer_views = ['Tag', 'Note',
                           'Edocument',
                           'ExperimentMeasureCalculation',
                           'ActionDef', 'Action', 'Workflow']

perform_create_views = ['PropertyDef', "MaterialProperty"]


def docstring(docstr, sep="\n"):
    """
    Decorator: Append to a function's docstring.
    """
    def _decorator(func):
        if func.__doc__ == None:
            func.__doc__ = docstr
        else:
            func.__doc__ = sep.join([func.__doc__, docstr])
        return func
    return _decorator
