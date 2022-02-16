from django import template

register = template.Library()

@register.filter(name="toUnderscore")
def toUnderscore(value):
    return value.replace(" ","_")