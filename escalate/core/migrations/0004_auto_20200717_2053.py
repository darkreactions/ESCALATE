# Generated by Django 2.2.14 on 2020-07-17 20:53

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0003_udfdef_viewsystemtooltype'),
    ]

    operations = [
        migrations.AlterModelTable(
            name='latestsystemtool',
            table='vw_systemtool',
        ),
    ]
