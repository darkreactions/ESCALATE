from django.db import connection as con

def experiment_copy(template_experiment_uuid, copy_experiment_description):
    """Wrapper of the ESCALATE postgres function experiment_copy"""
    cur = con.cursor()
    cur.callproc('experiment_copy', [template_experiment_uuid, copy_experiment_description])
    copy_experiment_uuid = cur.fetchone()[0]  # there will always be only one element in the tuple from this PG fn
    return copy_experiment_uuid

view_names = ['Material', 'Inventory', 'Actor', 'Organization', 'Person',
              'Systemtool', 'SystemtoolType', 'UdfDef', 'Status', 'Tag',
              'TagType', 'MaterialType', 'InventoryMaterial', 'Edocument']


def camel_to_snake(name):
    name = ''.join(['_'+i.lower() if i.isupper()
                    else i for i in name]).lstrip('_')
    return name
