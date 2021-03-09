from django import template

register = template.Library()

@register.filter
def index(indexible, args):
    return indexible[args] 
