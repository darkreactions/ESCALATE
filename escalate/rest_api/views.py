from django.shortcuts import render
from django.http import Http404

# Rest Imports
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework import generics


# App imports
from core.models import Actor, Person, Organization, Material, Inventory
from .serializers import (ActorSerializer, PersonSerializer,
                          OrganizationSerializer, MaterialSerializer,
                          InventorySerializer)


@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'organization': reverse('organization-list', request=request, format=format),
        'actor': reverse('actor-list', request=request, format=format),
        'person': reverse('person-list', request=request, format=format),
        'material': reverse('material-list', request=request, format=format),
        'inventory': reverse('inventory-list', request=request, format=format),

    })


class ActorList(APIView):
    queryset = Actor.objects.all()

    def get(self, request, format=None):
        actors = Actor.objects.all()
        serializer_context = {
            'request': request,
        }
        serializer = ActorSerializer(
            actors, many=True, context=serializer_context)
        return Response(serializer.data)


class ActorDetail(APIView):
    """
    Retrieve, an actor instance.
    """

    def get_object(self, pk):
        try:
            return Actor.objects.get(pk=pk)
        except Actor.DoesNotExist:
            raise Http404

    def get(self, request, pk, format=None):
        actor = self.get_object(pk)
        serializer = ActorSerializer(actor)
        return Response(serializer.data)


class PersonList(generics.ListAPIView):
    queryset = Person.objects.all()
    serializer_class = PersonSerializer


class PersonDetail(generics.RetrieveAPIView):
    queryset = Person.objects.all()
    serializer_class = PersonSerializer


class OrganizationList(generics.ListAPIView):
    queryset = Organization.objects.all()
    serializer_class = OrganizationSerializer


class OrganizationDetail(generics.RetrieveAPIView):
    queryset = Organization.objects.all()
    serializer_class = OrganizationSerializer


class MaterialList(generics.ListAPIView):
    queryset = Material.objects.all()
    serializer_class = MaterialSerializer


class MaterialDetail(generics.RetrieveAPIView):
    queryset = Material.objects.all()
    serializer_class = MaterialSerializer


class InventoryList(generics.ListAPIView):
    queryset = Inventory.objects.all()
    serializer_class = InventorySerializer


class InventoryDetail(generics.RetrieveAPIView):
    queryset = Inventory.objects.all()
    serializer_class = InventorySerializer
