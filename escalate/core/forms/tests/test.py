import pytest
import core.forms.forms as forms

# class ExampleForm(forms.Form):
#     name = forms.CharField(required=True)
#     age = forms.IntegerField(min_value=18)



@pytest.mark.parametrize(
    'description, validity',
    [('Hugo', True),
     ('Egon', True),
     ('Balder', True),
     ('', True),
     (None, True),
     ])
def test_example_form(description, validity):
    form = forms.SystemtoolTypeForm(data = {'description': description})
    # form = ExampleForm(data={
    #     'name': name,
    #     'age': age,
    # })

    assert form.is_valid() is validity