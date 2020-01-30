from django.shortcuts import render, redirect
from django.urls import reverse_lazy
from django.http import HttpResponse
from django.views import View
from django.views.generic.list import ListView

from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator

from plotly.offline import plot
from plotly.graph_objs import Scatter


class MainMenuView(View):
    template_name = 'core/main_menu.html'

    @method_decorator(login_required)
    def get(self, request, *args, **kwargs):
        x_data = [0, 1, 2, 3]
        y_data = [x**2 for x in x_data]
        plot_div = plot([Scatter(x=x_data, y=y_data,
                                 mode='lines', name='test',
                                 opacity=0.8, marker_color='green')],
                        output_type='div', include_plotlyjs=False)
        return render(request, self.template_name, context={'plot_div': plot_div})


class GenericListView(ListView):
    def get_queryset(self):
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'description')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                description__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super(GenericListView, self).get_context_data(**kwargs)
        context['filter'] = self.request.GET.get('filter', '')
        return context