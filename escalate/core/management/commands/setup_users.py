from django.core.management.base import BaseCommand, CommandError
from core.models.app_tables import CustomUser, OrganizationPassword
from core.models.view_tables import Person, Actor, Organization
from core.models import TypeDef
from django.contrib.auth.hashers import make_password


users = {
    'vshekar': {
        'person_data': {
            'first_name': 'Shekar',
            'last_name': 'V'

        },
        'password': 'copperhead123'
    },
    'mtynes': {
        'person_data': {
            'first_name': 'Mike',
            'last_name': 'Tynes'
        },
        'password': 'hello1world2'
    },
    'ichang': {
        'person_data':{
            'first_name': 'Isaac',
            'last_name': 'Chang'
        },
        'password': 'securepassword'
    },
    'jpannizzo': {
        'person_data': {
            'first_name': 'Joseph',
            'last_name': 'Pannizzo'
        },
        'password': 'password1'
    },
    'jkawamura': {
        'person_data': {
            'first_name': 'Joseph',
            'last_name': 'Kawamura'
        },
        'password': 'password2'
    }
}

org_passwords = {
    'LBL' : 'test',
    'HC' : 'test',
    'NL' : 'test',
    'TC': 'test',
}

# organizations = [{'description' : 'Lawrence Berkeley',
#                  'full_name' : 'Lawrence Berkeley',
#                  'short_name' : 'LBL'},
#                  {'description' : 'Haverford College',
#                  'full_name' : 'Haverford College',
#                  'short_name' : 'HC'},
#                  {'description' : 'Norquist Lab',
#                  'full_name' : 'Norquist Lab',
#                  'short_name' : 'NL'},
#                  {'description' : 'TestCo',
#                  'full_name' : 'TestCo',
#                  'short_name' : 'TC'},]

# type_defs = [
#     {'category': 'data', 'description': 'text'},
#     {'category': 'data', 'description': 'num'},
#     {'category': 'data', 'description': 'int'},
#     {'category': 'data', 'description': 'array_int'},
#     {'category': 'data', 'description': 'array_num'},
#     {'category': 'data', 'description': 'bool'},
# ]


class Command(BaseCommand):
    help = 'Sets up users after a database refresh'

    def handle(self, *args, **options):
        for username, data in users.items():
            person, created = Person.objects.get_or_create(**data['person_data'])
            if created:
                self.stdout.write(self.style.NOTICE(f'Created {person}, previosuly did not exist'))
            p = Person.objects.get(pk=person.pk)
            user, created = CustomUser.objects.get_or_create(username=username, person=p)
            if not created:
                user.person = p
            user.set_password(data['password'])
            user.is_superuser = True
            user.is_staff = True
            user.save()
            self.stdout.write(self.style.SUCCESS(f'Created User {username}'))

        # for org in organizations:
        #     o = Organization(**org)
        #     o.save()
        #     self.stdout.write(self.style.SUCCESS(f'Created Organization {o}'))
        
        # for td in type_defs:
        #     t = TypeDef(**td)
        #     t.save()
        #     self.stdout.write(self.style.SUCCESS(f'Created Typedef {t}'))

        for short_name, raw_password in org_passwords.items():
            org = Organization.objects.get(short_name=short_name)
            org_pwd, created = OrganizationPassword.objects.get_or_create(organization=org)
            org_pwd.password = make_password(raw_password)
            org_pwd.save()
            self.stdout.write(self.style.SUCCESS(f'Created org password: {short_name}'))

           # add all users to org
            for username, data in users.items():
                person = Person.objects.get(**data['person_data'])
                organization = Organization.objects.get(full_name=org.full_name)  # need to get from view table
                actor, created = Actor.objects.get_or_create(person=person, organization=organization)
                self.stdout.write(self.style.SUCCESS(f'Added user {person} to org {org}'))
