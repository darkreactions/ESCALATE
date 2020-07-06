from core.models.view_tables import Material
from django.shortcuts import render
from django.forms import formset_factory
from core.forms import AddReagentForm


def materials(response):
    materials = Material.objects.all()
    curr_reagents = 1

    if response.method == "POST":
        if response.POST.get("save"):
            print('Saving reagent!')
            print([item for item in response.POST.items()])
            if 'reagent1' in response.POST:
                print(response.POST.getlist('reagent1'))

        elif response.POST.get("newReagent"):
            curr_reagents = int(response.POST.get("currReagents"))
            curr_reagents += 1

    context = {"materials": materials,
               'curr_reagents': range(1, curr_reagents+1)}
    return render(response, "core/capture/capture_form.html", context)


def materials2(response):
    curr_reagents = 1
    AddReagentFormSet = formset_factory(AddReagentForm, extra=curr_reagents)
    if response.method == "POST":
        if response.POST.get("save"):
            print('Saving reagent!')
            formset = AddReagentFormSet(response.POST)
            if formset.is_valid():
                print(formset.cleaned_data)
        elif response.POST.get("newReagent"):
            curr_reagents = int(response.POST.get("currReagents"))
            curr_reagents += 1

    data = {
        'form-TOTAL_FORMS': str(curr_reagents),
        'form-INITIAL_FORMS': '0',
        'form-MAX_NUM_FORMS': '',
        'form-0-title': 'Reagent 1  ',
        'form-0-pub_date': '',
    }

    context = {'formset': AddReagentFormSet(data),
               'curr_reagents': range(1, curr_reagents+1)
               }
    return render(response, "core/capture/capture_form2.html", context)
