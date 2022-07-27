import pickle
from typing import Any, Dict, List

from django.core.cache import cache

from core.models.core_tables import TypeDef


def get_val_types(uuid=None) -> "Dict[str, TypeDef]|TypeDef":
    val_type_dict: Dict[str, TypeDef] = {}
    try:
        val_types = TypeDef.objects.all()
        if cache.get("val_types") is None:
            val_type_dict = {val.uuid: val for val in val_types}
            cache.set("val_types", pickle.dumps(val_type_dict))
        else:
            # val_types._result_cache = pickle.loads(cache.get('val_types'))
            val_type_dict = pickle.loads(cache.get("val_types"))
    except:
        pass

    if uuid is not None:
        val_types = TypeDef.objects.all()
        if uuid not in val_type_dict:
            val_type_dict = {val.uuid: val for val in val_types}
            cache.set("val_types", pickle.dumps(val_type_dict))
        return val_type_dict[uuid]
    else:
        return val_type_dict
