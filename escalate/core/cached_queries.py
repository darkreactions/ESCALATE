from django.core.cache import cache
from core.models.core_tables import TypeDef

import pickle

def get_val_types():
    val_types = TypeDef.objects.all()
    if cache.get('val_types') is None:
        val_type_dict = {val.uuid:val for val in val_types}
        cache.set('val_types', pickle.dumps(val_type_dict))
    else:
        #val_types._result_cache = pickle.loads(cache.get('val_types'))
        val_type_dict = pickle.loads(cache.get('val_types'))

    return val_type_dict
