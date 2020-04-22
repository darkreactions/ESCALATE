# builtin imports
import types
import tempfile

# Django imports
from django.shortcuts import render, HttpResponse
from django.http import Http404, FileResponse

# Rest Imports
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.generics import ListAPIView, RetrieveAPIView
from django_filters import rest_framework as filters
from url_filter.integrations.drf import DjangoFilterBackend


# App imports

from .serializers import *
from .utils import camel_case_uuid, camel_case, view_names, custom_serializer_views
import core.models
import rest_api
from .rest_docs import rest_docs


view_names = view_names + custom_serializer_views


@api_view(['GET'])
def api_root(request, format=None):
    """
    ## Table data list
    The links at the bottom of the page, return table data. For example http://escalate.sd2e.org/api/inventory/ returns data in the following format

    ```
    {
    "count": 131,
    "next": "http://escalate.sd2e.org/api/inventory/?limit=100&offset=100",
    "previous": null,
    "results": [
        {
            "url": "http://escalate.sd2e.org/api/inventory/86a86f95-7611-4b2a-94c0-ede4259bf756/",
            "inventory_description": "N,N-Diethylpropane-1,3-diammonium iodide",
            "part_no": "MS123223-100",
            "onhand_amt": 185.5,
            "unit": "g",
            "create_date": "2019-06-01T00:00:00Z",
            "expiration_date": null,
            "inventory_location": null,
            "status": null,
            "material_description": "N,N-Diethylpropane-1,3-diammonium iodide",
            "description": "Zhi Li",
            "edocument_description": null,
            "notetext": null,
            "material_uuid": "http://escalate.sd2e.org/api/material/817fdd3f-50d8-4eff-a0ec-34f2920dd06c/",
            "actor_uuid": "http://escalate.sd2e.org/api/actor/df59bed1-9da9-41ca-8b69-cf6c1c207fe2/",
            "edocument_uuid": null,
            "note_uuid": null
        },
    }
    ```

    The returned json includes 100 table data rows and meta-data such as:

    1. count - The total number of results matching the request
    2. next - The url leading to the next page of results
    3. previous - The url leading to the previous page of results
    4. results - List of table rows

    ## Filters
    Data in the `results` list can be filtered using many different url options 
    that can be added to the end of the table's url of the format <table_url\>/?<filter_option_1\>&<filter_option_2\>&...
    All filters except 'exact match' expect a keyword that follows the column 
    name it is applied to, by a double underscore (__)

    ### Exact Matches
    Add the column name the the value to the matched to the url

    For example, `http://escalate.sd2e.org/api/person/?firstname=Gary`
    will display person table rows where the `firstname` column
    is equal to value `Gary`

    ### Related tables
    Filters can also be applied based on columns in related tables

    For example, `http://escalate.sd2e.org/api/person/?organization__short_name=HC`
    will display person table rows where the `short_name` of the `organization` table is `HC`

    ### Case insensitive exact match (iexact)
    Ignores case while matching column values

    For example, `http://escalate.sd2e.org/api/person/?firstname__iexact=garY`
    will display person table rows where the `firstname` column
    is equal to value `garY` disregarding case

    ### Case sensitive containment test (contains)
    Filters rows based on whether specified column contains a particular substring

    For example, `http://escalate.sd2e.org/api/person/?lastname__contains=briga`
    will display person table rows where the `lastname` column
    contains the substring `briga` 

    ### Case insensitive containment test (icontains)
    Similar to `contains` without the case sensitivity

    ### List membership (in)
    Filters based on muliple values from a list
    For example, `http://escalate.sd2e.org/api/person/?firstname__in=Gary,Mansoor`
    will display person table rows where the `firstname` column
    is equal `Gary` or `Mansoor`

    ### Value comparison (gt, gte, lt, lte)
    Filters that compare numerical values. Where the keywords correspond to 

    1. gt - Strictly greater than
    2. gte - Greater than or equal to
    3. lt - Strictly less than
    4. lte - Less than or equal to

    For example, `http://escalate.sd2e.org/api/person/?add_date__year__gte=2020`
    will display person table rows where the year in the add_date column is greater than or equal to 2020

    ### String starts with (startwith, istartswith)
    Filters columns based on whether a column starts with a particular string

    For example, `http://escalate.sd2e.org/api/person/?firstname__startswith=Man`
    will display person table rows where the `firstname` column starts with `Man`

    ### String ends with (endswith, iendswith)
    Filters columns based on whether a column ends with a particular string

    For example, `http://escalate.sd2e.org/api/person/?firstname__endswith=soor`
    will display person table rows where the `firstname` column starts with `soor`

    ### Range of values (range)
    Filters columns whose value lies between a given range 

    For example, `http://escalate.sd2e.org/api/person/?add_date__year__range=2015,2020`
    will display person table rows where the year in the add_date column is between 2015 and 2020

    ### Negate filter (!)
    Negates the filter being used

    For example, `http://escalate.sd2e.org/api/person/?firstname__startswith!=Man`
    will display person table rows where the `firstname` column **does not** start with `Man`





    """
    response_object = {}

    for view_name in view_names:
        name = camel_case(view_name)
        response_object[name] = reverse(
            name+'-list', request=request, format=format)

    return Response(response_object)


"""
Hopefully DRY way to generate classes for table lists and details

Generates classes of the form:

class <model>List(ListAPIView):
    queryset = <model>.objects.all()
    serializer_class = <model>Serializer


class <model>Detail(RetrieveAPIView):
    queryset = <model>.objects.all()
    serializer_class = <model>Serializer
"""


def create_view(model_name, lookup_field=None):
    model = getattr(core.models, model_name)
    modelSerializer = getattr(rest_api.serializers, model_name+'Serializer')

    methods_list = {"queryset": model.objects.all(),
                    "serializer_class": modelSerializer,
                    "name": camel_case(model_name)+'-list',
                    "filter_backends": [DjangoFilterBackend],
                    "filter_fields": '__all__',
                    "__doc__": rest_docs.get(model_name, '')
                    }
    #
    #

    methods_detail = {"queryset": model.objects.all(),
                      "serializer_class": modelSerializer,
                      "name": camel_case(model_name)+'-detail'}
    globals()[model_name+'List'] = type(model_name + 'List',
                                        tuple([ListAPIView]), methods_list)
    globals()[model_name+'Detail'] = type(model_name + 'Detail',
                                          tuple([RetrieveAPIView]), methods_detail)


for view_name in view_names:
    lookup_field = camel_case_uuid(view_name)
    create_view(view_name, lookup_field)

create_view('Edocument')


# Download file view
def download_blob(request, uuid):
    edoc = core.models.Edocument.objects.get(edocument_uuid=uuid)
    contents = edoc.edocument
    filename = edoc.filename
    testfile = tempfile.TemporaryFile()
    testfile.write(contents)
    testfile.seek(0)
    response = FileResponse(testfile, as_attachment=True,
                            filename=filename)

    #response['Content-Disposition'] = 'attachment; filename=blob.pdf'
    return response
