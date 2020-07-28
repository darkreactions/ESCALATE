

view_names = ['Material', 'Inventory', 'Actor', 'Organization', 'Person',
              'Systemtool', 'SystemtoolType', 'UdfDef', 'Status', 'Tag',
              'TagType', 'MaterialType', ]


def camel_to_snake(name):
    return ''.join(['_'+i.lower() if i.isupper()
                    else i for i in name]).lstrip('_')
