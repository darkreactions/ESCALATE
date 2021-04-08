from django import template

register = template.Library()

@register.filter(name='index')
def index(indexible, args):
    return indexible[args] 
