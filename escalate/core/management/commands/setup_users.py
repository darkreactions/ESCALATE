from django.core.management.base import BaseCommand, CommandError
from core.models.app_tables import CustomUser, OrganizationPassword
from core.models.core_tables import PersonTable, OrganizationTable
from core.models.view_tables import Person
from django.contrib.auth.hashers import make_password


users = {
    'vshekar': {
        'person_data': {
            'first_name': 'Shekar',
            'last_name': 'V'

        },
        'password': 'copperhead123'
    }
}

org_passwords = {
    'LBL' : 'test',
    'HC' : 'test',
    'NL' : 'test'
}


class Command(BaseCommand):
    help = 'Sets up users after a database refresh'

    def handle(self, *args, **options):
        for username, data in users.items():
            person, created = Person.objects.get_or_create(**data['person_data'])
            p = PersonTable.objects.get(pk=person.pk)
            user, created = CustomUser.objects.get_or_create(username=username, person=p)
            user.set_password(data['password'])
            user.is_superuser = True
            user.is_staff = True
            user.save()
            self.stdout.write(self.style.SUCCESS(f'Created User {username}'))

        for short_name, raw_password in org_passwords.items():
            org = OrganizationTable.objects.get(short_name=short_name)
            org_pwd, created = OrganizationPassword.objects.get_or_create(organization=org)
            org_pwd.password = make_password(raw_password)
            org_pwd.save()
            self.stdout.write(self.style.SUCCESS(f'Created org password: {short_name}'))