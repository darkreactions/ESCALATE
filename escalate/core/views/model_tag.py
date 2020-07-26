from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, UpdateView
from django.forms import modelformset_factory
from django.shortcuts import redirect

from core.models import Tag, Tag_X, Actor
from core.forms import TagForm
#from core.views.menu import GenericListView

class ModelTagEdit:
    template_name = 'core/generic/add_tag.html'
    model = Tag
    tag_model_name = ""
    form_class = TagForm
    TagFormSet = modelformset_factory(Tag, form=TagForm,can_delete=True)
    tag_forms = TagFormSet(queryset=Tag.objects.none(),prefix='tag')
    success_url = reverse_lazy(f'{tag_model_name}_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['tag_forms'] = self.tag_forms
        context['title'] = 'Tag'
        return context

    def post(self, request, *args, **kwargs):
        model_pk = self.kwargs['pk']
        model_name = request.session.get('model_name')
        self.tag_model_name = model_name
        print(request.POST)
        if request.POST.get('cancel'):
            #self.success_url = reverse_lazy(f'{model_name}_update',kwargs={'pk':model_pk})
            #above url not being redirected to in super.post so I brute-forced redirect
            return redirect(f'/{model_name}/{model_pk}')
        elif request.POST.get('another_tag'):
            #Functionality plan block
            #add another tag form to the new tag forms
            #should re-render the page with a formset with post info to have the
            #current new forms and a new empty tag form
            #none of the forms in the formset are submitted
            if self.TagFormSet != None:
                # new_set = self.TagFormSet(request.POST, prefix='tag')
                # self.tag_forms = new_set
                pass
            self.success_url = reverse_lazy('model_tag_update',kwargs={'pk':model_pk})
        else:
            #save all new forms for tags made
            if self.TagFormSet != None:
                formset = self.TagFormSet(request.POST,prefix='tag')
                actor = Actor.objects.get(
                    person_uuid=request.user.person.pk)
                # Loop through every tag form
                for form in formset:
                    # Only if the form has changed make an update, otherwise ignore
                    if form.has_changed() and form.is_valid():
                        if request.user.is_authenticated:
                            tag = form.save(commit=False)
                            tag.actor_uuid = actor
                            tag.save()
                            if form not in formset.deleted_forms:
                            # if tag not being deleted make tag_x to relate the tag and
                            # the person being tagged
                                tag_x = Tag_X()
                                tag_x.tag_uuid=Tag.objects.get(display_text=tag.display_text)
                                tag_x.ref_tag_uuid=model_pk
                                tag_x.add_date=tag.add_date
                                tag_x.mod_date=tag.mod_date
                                tag_x.save()
                formset.save(commit=False)
                for form in formset.deleted_forms:
                    form.instance.delete()
            #self.success_url = reverse_lazy(f'{model_name}_update',kwargs={'pk':model_pk})
            #above url not being redirected to in super.post so I brute-forced redirect
            return redirect(f'/{model_name}/{model_pk}')
        return super().post(request, *args, **kwargs)

class ModelTagCreate(ModelTagEdit, CreateView):
    pass

class ModelTagUpdate(ModelTagEdit, UpdateView):
    pass
