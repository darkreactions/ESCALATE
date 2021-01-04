from django.db import models
from core.models.core_tables import RetUUIDField
from core.models.custom_types import ValField


class Calculation(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='calculation_uuid')
    in_val = ValField(max_length=255, blank=True, null=True)
    """
    in_val_type = models.ForeignKey('TypeDef',
                                    models.DO_NOTHING,
                                    db_column='in_val_type_uuid',
                                    related_name='calculation_in_val_type', editable=False)
    in_val_value = models.TextField(blank=True, null=True, editable=False)
    in_val_unit = models.TextField(blank=True, null=True, editable=False)
    """
    in_val_edocument = models.ForeignKey('Edocument',
                                         models.DO_NOTHING,
                                         db_column='in_val_edocument_uuid',
                                         related_name='calculation_in_val_edocument', editable=False)

    # in opt
    in_opt_val = ValField(max_length=255, blank=True, null=True)
    #in_opt_val = CharField(max_length=255, blank=True, null=True)
    """
    in_opt_val_value = models.TextField(blank=True, null=True, editable=False)
    in_opt_val_type = models.ForeignKey('TypeDef',
                                        models.DO_NOTHING,
                                        related_name='calculation_in_opt_val_type',
                                        db_column='in_opt_val_type_uuid',
                                        blank=True, null=True, editable=False)
    in_opt_val_unit = models.TextField(blank=True, null=True, editable=False)
    """
    in_opt_val_edocument = models.ForeignKey('Edocument',
                                             models.DO_NOTHING,
                                             db_column='in_opt_val_edocument_uuid',
                                             related_name='calculation_in_opt_val_edocument', editable=False)
    # out
    out_val = ValField(max_length=255, blank=True, null=True)
    #out_val = CharField(max_length=255, blank=True, null=True)
    """
    out_val_type = models.ForeignKey('TypeDef',
                                     models.DO_NOTHING,
                                     related_name='calculation_out_val_type',
                                     db_column='out_val_type_uuid',
                                     blank=True, null=True, editable=False)
    out_val_value = models.TextField(blank=True, null=True, editable=False)
    out_val_unit = models.TextField(blank=True, null=True, editable=False)
    """
    out_val_edocument = models.ForeignKey('Edocument',
                                          models.DO_NOTHING,
                                          db_column='out_val_edocument_uuid',
                                          related_name='calculation_out_val_edocument', editable=False)

    calculation_alias_name = models.CharField(
        max_length=255, blank=True, null=True)

    status = models.ForeignKey('Status',
                               models.DO_NOTHING,
                               db_column='calculation_status_uuid',
                               related_name='calculation_status')
    status_description = models.CharField(max_length=255,
                                          blank=True, null=True)
    calculation_def = models.ForeignKey('CalculationDef',
                                        models.DO_NOTHING,
                                        blank=True, null=True,
                                        db_column='calculation_def_uuid',
                                        related_name='calculation_calculation_def')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)

    description = models.CharField(max_length=1023, blank=True, null=True)

    systemtool = models.ForeignKey('Systemtool',
                                   models.DO_NOTHING,
                                   db_column='systemtool_uuid',
                                   related_name='calculation_systemtool')
    """
    systemtool_name = models.CharField(max_length=1023, blank=True, null=True)
    systemtool_type_description = models.CharField(
        max_length=1023, blank=True, null=True)
    systemtool_vendor_organization = models.CharField(
        max_length=1023, blank=True, null=True, db_column='systemtool_vendor_organization')
    systemtool_version = models.CharField(
        max_length=1023, blank=True, null=True)
    """
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True,
        related_name='calculation_actor')
    #actor_description = models.CharField(
    #    max_length=1023, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_calculation'


class CalculationDef(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='calculation_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=1023, blank=True, null=True)
    parameter_def = models.ManyToManyField('ParameterDef', 
                                           through='CalculationParameterDefAssign', 
                                           related_name='calculation_def_parameter_def')
    in_source = models.ForeignKey('CalculationDef',
                                models.DO_NOTHING,
                                db_column='in_source_uuid',
                                related_name='calculation_def_in_source')
    in_type = models.ForeignKey('TypeDef',
                                models.DO_NOTHING,
                                db_column='in_type_uuid',
                                related_name='calculation_def_in_type')
    in_opt_source = models.ForeignKey('CalculationDef',
                                models.DO_NOTHING,
                                db_column='in_opt_source_uuid',
                                related_name='calculation_def_in_opt_source')
    in_opt_type = models.ForeignKey('TypeDef',
                                models.DO_NOTHING,
                                db_column='in_opt_type_uuid',
                                related_name='calculation_def_in_opt_type')
    out_type = models.ForeignKey('TypeDef',
                                 models.DO_NOTHING,
                                 blank=True, null=True,
                                 db_column='out_type_uuid',
                                 related_name='calculation_def_out_type')
    systemtool = models.ForeignKey('Systemtool',
                                   models.DO_NOTHING,
                                   db_column='systemtool_uuid', 
                                   related_name='calculation_def_systemtool')
    actor = models.ForeignKey('Actor', models.DO_NOTHING, blank=True, 
                              null=True, db_column='actor_uuid', 
                              related_name='calculation_def_actor')
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_calculation_def'

    def __str__(self):
        return "{}".format(self.description)


class CalculationParameterDefAssign(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='calculation_parameter_def_x_uuid')
    parameter_def = models.ForeignKey('ParameterDef',
                                          on_delete=models.DO_NOTHING,
                                          db_column='parameter_def_uuid',
                                          blank=True,
                                          null=True,
                                          related_name='calculation_parameter_def_assign_parameter_def')
    calculation_def = models.ForeignKey('CalculationDef',
                                          on_delete=models.DO_NOTHING,
                                          db_column='calculation_def_uuid',
                                          blank=True,
                                          null=True,
                                          related_name='calculation_parameter_def_assign_calculation_def')
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_calculation_parameter_def_assign'


class Edocument(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='edocument_uuid', editable=False)
    title = models.CharField(max_length=255, blank=True,
                             null=True, db_column='title')
    description = models.CharField(max_length=255, blank=True, null=True,
                                   db_column='description')
    filename = models.CharField(max_length=255, blank=True, null=True,
                                db_column='filename')
    source = models.CharField(
        max_length=255, blank=True, null=True, db_column='source')
    edoc_type = models.CharField(max_length=255, blank=True,
                                 null=True, db_column='doc_type_description')
    edocument = models.BinaryField(blank=True, null=True, editable=False)
    edoc_ver = models.CharField(max_length=255, blank=True,
                                null=True, db_column='doc_ver')
    doc_type_uuid = models.ForeignKey('TypeDef', db_column='doc_type_uuid',
                                      on_delete=models.DO_NOTHING, blank=True, null=True, editable=False)
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True, related_name='edocument_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='edocument_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    edocument_x_uuid = RetUUIDField(editable=False)
    ref_edocument_uuid = RetUUIDField()

    class Meta:
        managed = False
        db_table = 'vw_edocument'

    def __str__(self):
        return "{}".format(self.title)


class Measure(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='measure_uuid')
    measure_type = models.ForeignKey('MeasureType',
                                          on_delete=models.DO_NOTHING,
                                          db_column='measure_type_uuid',
                                          blank=True,
                                          null=True,
                                          related_name='measure_measure_type')
    ref_measure = models.ForeignKey('Measure',
                                         on_delete=models.DO_NOTHING,
                                         db_column='ref_measure_uuid',
                                         blank=True,
                                         null=True,
                                         related_name='measure_ref_measure')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   )
    measure_value = ValField(max_length=255, )
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   related_name='measure_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         editable=False)
    status_uuid = models.ForeignKey('Status',
                                    on_delete=models.DO_NOTHING,
                                    db_column='status_uuid',
                                    blank=True,
                                    null=True,
                                    related_name='measure_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_measure'


class MeasureType(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='measure_type_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False, related_name='measure_type_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         editable=False)
    status_uuid = models.ForeignKey('Status',
                                    on_delete=models.DO_NOTHING,
                                    db_column='status_uuid',
                                    blank=True,
                                    null=True,
                                    editable=False, related_name='measure_type_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_measure_type'


class MeasureX(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='measure_x_uuid')
    ref_measure = RetUUIDField(db_column='ref_measure_uuid')
    measure = models.ForeignKey('Measure', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             editable=False,
                             db_column='measure_uuid',
                             related_name='measure_x_measure')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'measure_x'

    def __str__(self):
        return "{}".format(self.measure_uuid)


class MeasureDef(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='measure_def_uuid')
    default_measure_type = models.ForeignKey('MeasureType', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             db_column='default_measure_type_uuid',
                             related_name='measure_def_default_measure_type')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    default_measure_value = ValField(max_length=255, )
    property_def = models.ForeignKey('PropertyDef', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             db_column='property_def_uuid',
                             related_name='measure_def_default_measure_type')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='measure_def_actor')
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='measure_def_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_measure_def'  


class Note(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='note_uuid')
    notetext = models.TextField(blank=True, null=True,
                                verbose_name='Note Text')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid', related_name='note_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    """
    note_x_uuid = models.ForeignKey('Note_x', models.DO_NOTHING,
                                  blank=True,
                                  null=True,
                                  editable=False,
                                  db_column='note_x_uuid',
                                  related_name='note_note_x')
    """
    ref_note_uuid = RetUUIDField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_note'

    def __str__(self):
        return "{}".format(self.notetext)


class Note_x(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='note_x_uuid')
    ref_note = RetUUIDField(db_column='ref_note_uuid')
    note = models.ForeignKey('Note', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             editable=False,
                             db_column='note_uuid',
                             related_name='note_x_note')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'note_x'

    def __str__(self):
        return "{}".format(self.note_uuid)


class Parameter(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='parameter_uuid')
    parameter_def = models.ForeignKey('ParameterDef',
                                      db_column='parameter_def_uuid',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      editable=False, related_name='parameter_parameter_def')
    parameter_def_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 db_column='parameter_def_description',
                                                 editable=False)
    parameter_val = ValField(max_length=255, blank=True,
                             null=True,
                             db_column='parameter_val')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='parameter_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='parameter_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_parameter'


class ParameterDef(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='parameter_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='parameter_def_val_type')
    default_val = ValField(max_length=255, db_column='default_val')
    
    """
    default_val_val = models.CharField(max_length=255,
                                       blank=True,
                                       null=True,
                                       db_column='default_val_val',
                                       editable=False)
    valunit = models.CharField(max_length=255,
                               blank=True,
                               null=True,
                               db_column='valunit',
                               editable=False)
    val_type_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='val_type_description',
                                            editable=False)
    default_val = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='default_val',
                                   editable=False)
    
    required = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='required',
                                editable=False)
    """
    required = models.BooleanField(blank=True, null=True)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='parameter_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='parameter_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_parameter_def'


class Property(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='property_uuid')

    property_def = models.ForeignKey('PropertyDef',
                                     db_column='property_def_uuid',
                                     on_delete=models.DO_NOTHING,
                                     blank=True,
                                     null=True, related_name='property_property_def')
    short_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='short_description')
    property_val = ValField(max_length=255, 
                                   blank=True,
                                   null=True,
                                   db_column='property_val')
    
    """
    # TODO: Any way to represent arrays with sqaure brackets? One of the arrays
    # is represented as \"{0.5,10}\" in the val string. We'll have to write a special 
    # case to parse arrays in custom_types.py/Val.from_db() function
    
    property_val = ValField(max_length=255, max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='property_val')
    property_val = models.CharField(max_length=255,
                                    blank=True,
                                    null=True,
                                    db_column='property_val')
    """
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='property_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='status_uuid', related_name='property_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_property'

    def __str__(self):
        return "{}".format(self.short_description)


class PropertyDef(models.Model):

    uuid = RetUUIDField(primary_key=True,
                        db_column='property_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    short_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='short_description')
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_def_val_type')
    val_unit = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='valunit')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='property_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='status_uuid', related_name='property_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_property_def'

    def __str__(self):
        return "{}".format(self.description)


class Status(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='status_uuid')
    description = models.CharField(max_length=255, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_status'

    def __str__(self):
        return "{}".format(self.description)


class Tag(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='tag_uuid', editable=False)
    display_text = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True, null=True, related_name='tag_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)

    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    tag_type = models.ForeignKey('TagType', models.DO_NOTHING,
                                 db_column='tag_type_uuid',
                                 blank=True, null=True, related_name='tag_tag_type')
    type = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    type_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)

    class Meta:
        managed = False
        db_table = 'vw_tag'

    def __str__(self):
        return "{}".format(self.display_text)


class TagAssign(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='tag_x_uuid')
    ref_tag = RetUUIDField(db_column='ref_tag_uuid')
    tag = models.ForeignKey('Tag', models.DO_NOTHING,
                            blank=True,
                            null=True,
                            db_column='tag_uuid', related_name='tag_assign_tag')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_tag_assign'

    def __str__(self):
        return "{}".format(self.uuid)


class TagType(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='tag_type_uuid')
    type = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_tag_type'

    def __str__(self):
        return "{}".format(self.type)


class Udf(models.Model):
    """
    UDF = User Defined Field
    For example, say we wanted to start tracking ‘challenge problem #’ with an experiment. 
    Instead of creating a new column in experiment, we could define a udf 
    (udf_def) and it’s associated value (val) type, in this case say: text. 
    Then we could allow the user (API) to create a specific instance of that 
    udf_def, and associate it with a specific experiment, 
    where the experiment_uuid is the ref_udf_uuid.
    """
    uuid = RetUUIDField(primary_key=True, db_column='udf_uuid')
    udf_def = models.ForeignKey('UdfDef', models.DO_NOTHING,
                            blank=True, null=True,
                            db_column='udf_def_uuid', related_name='udf_udf_def')
    description = models.CharField(max_length=255,  null=True)
    udf_value = ValField(max_length=255, db_column='udf_val')
    udf_val_edocument = models.ForeignKey('Edocument', models.DO_NOTHING,
                            blank=True, null=True,
                            db_column='udf_val_edocument_uuid', 
                            related_name='udf_udf_val_edocument')
    ref_udf = RetUUIDField(db_column='ref_udf_uuid')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = False
        db_table = 'vw_udf'
    def __str__(self):
        return "{}".format(self.description)
    

class UdfDef(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='udf_def_uuid')
    description = models.CharField(
        max_length=255,  null=True)
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='udf_def_val_type')
    val_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    unit = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_udf_def'

    def __str__(self):
        return "{}".format(self.description)

