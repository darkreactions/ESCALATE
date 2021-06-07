from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.db.models.fields import BooleanField
from core.models.core_tables import RetUUIDField
from core.models.custom_types import ValField, PROPERTY_CLASS_CHOICES, PROPERTY_DEF_CLASS_CHOICES, MATERIAL_CLASS_CHOICES
from django.contrib.postgres.fields import ArrayField
import uuid
from core.models.abstract_base_models import DateColumns, StatusColumn, ActorColumn

managed_tables = True
managed_views = False

class Calculation(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='calculation_uuid')
    in_val = ValField( blank=True, null=True)
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
    in_opt_val = ValField( blank=True, null=True)
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
    out_val = ValField( blank=True, null=True)
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
    

    class Meta:
        managed = managed_tables
        db_table = 'calculation'


class CalculationDef(DateColumns, ActorColumn):
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


    class Meta:
        managed = managed_tables
        db_table = 'calculation_def'

    def __str__(self):
        return "{}".format(self.description)


class CalculationParameterDefAssign(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='calculation_parameter_def_x_uuid')
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

    class Meta:
        managed = managed_views
        db_table = 'vw_calculation_parameter_def_assign'


class Edocument(DateColumns, StatusColumn, ActorColumn):
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
    edoc_type_uuid = models.ForeignKey('TypeDef', db_column='doc_type_uuid',
                                      on_delete=models.DO_NOTHING, blank=True, null=True, editable=False)
    #edocument_x_uuid = RetUUIDField(editable=False)
    ref_edocument_uuid = RetUUIDField()

    class Meta:
        managed = managed_tables
        db_table = 'edocument'

    def __str__(self):
        return "{}".format(self.title)


class EdocumentX(DateColumns):
    uuid = RetUUIDField(primary_key=True, db_column='edocument_x_uuid', editable=False)
    ref_edocument_uuid = RetUUIDField()
    edocument = models.ForeignKey('Edocument',
                                          on_delete=models.DO_NOTHING,
                                          db_column='edocument_uuid',
                                          blank=True,
                                          null=True,
                                          related_name='edocument_x_edocument')

    class Meta:
        managed = managed_tables
        db_table = 'edocument_x'


class Measure(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='measure_uuid')
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
    measure_def = models.ForeignKey('MeasureDef',
                                    db_column='measure_def_uuid',
                                    on_delete=models.DO_NOTHING)
    measure_value = ValField()

    class Meta:
        managed = managed_tables
        db_table = 'measure'


class MeasureType(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='measure_type_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)

    def __str__(self):
        return f'{self.description}'

    class Meta:
        managed = managed_tables
        db_table = 'measure_type'


class MeasureX(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='measure_x_uuid')
    ref_measure = RetUUIDField(db_column='ref_measure_uuid')
    measure = models.ForeignKey('Measure', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             editable=False,
                             db_column='measure_uuid',
                             related_name='measure_x_measure')

    class Meta:
        managed = managed_tables
        db_table = 'measure_x'

    def __str__(self):
        return "{}".format(self.measure_uuid)


class MeasureDef(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='measure_def_uuid')
    default_measure_type = models.ForeignKey('MeasureType', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             db_column='default_measure_type_uuid',
                             related_name='measure_def_default_measure_type')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    default_measure_value = ValField( )
    property_def = models.ForeignKey('PropertyDef', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             db_column='property_def_uuid',
                             related_name='measure_def_default_measure_type')

    def __str__(self):
        return f'{self.description}'

    class Meta:
        managed = managed_tables
        db_table = 'measure_def'

"""
class NoteTest(DateColumns, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='note_uuid')
    notetext = models.TextField(blank=True, null=True,
                                verbose_name='Note Text')
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    ref_note_uuid = RetUUIDField(blank=True, null=True)
    content_object = GenericForeignKey('content_type', 'ref_note_uuid')

    class Meta:
        managed = True
        db_table = 'note_test'

    def __str__(self):
        return "{}".format(self.notetext)
"""


class Note(DateColumns, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='note_uuid')
    notetext = models.TextField(blank=True, null=True,
                                verbose_name='Note Text')
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
        managed = managed_tables
        db_table = 'note'

    def __str__(self):
        return "{}".format(self.notetext)


class NoteX(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='note_x_uuid')
    ref_note = RetUUIDField(db_column='ref_note_uuid')
    note = models.ForeignKey('Note', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             editable=False,
                             db_column='note_uuid',
                             related_name='note_x_note')

    class Meta:
        managed = managed_tables
        db_table = 'note_x'

    def __str__(self):
        return "{}".format(self.note_uuid)


class Parameter(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='parameter_uuid')
    parameter_def = models.ForeignKey('ParameterDef',
                                      db_column='parameter_def_uuid',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      related_name='parameter_parameter_def')
    parameter_val_nominal = ValField( blank=True,
                             null=True,
                             db_column='parameter_val')
    parameter_val_actual = ValField( blank=True,
                             null=True,
                             db_column='parameter_val_actual')
    ref_object = RetUUIDField(blank=True, null=True)
    """
    # Parameter should be related to only 1 action unlike parameter_def to action_def
    # Therefore, we don't need a cross table like parameter_x but a direct foreign key
    # This should hold true even if parameter is related to other entities besides
    # action. Currently, also associated with calculation 
    action = models.ForeignKey('Action',
                                on_delete=models.DO_NOTHING,
                                blank=True,
                                null=True,
                                editable=False, related_name='parameter_action')
    """
    class Meta:
        managed = managed_tables
        db_table = 'parameter'

class ParameterX(DateColumns):
    uuid =RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='parameter_x_uuid')
    #parameter_uuid = RetUUIDField(db_column='parameter_uuid')
    parameter_ref_uuid = RetUUIDField(db_column='ref_parameter_uuid')
    parameter = models.ForeignKey('Parameter', on_delete=models.DO_NOTHING,
                                blank=True,
                                null=True,
                                related_name='parameter_x_parameter')
    
    
    class Meta:
        managed = managed_tables
        db_table = 'parameter_x'


class ParameterDef(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='parameter_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    default_val = ValField(db_column='default_val')
    required = BooleanField()
    unit_type = models.CharField(max_length=255,
                                 blank=True,
                                 null=True,
                                 db_column='parameter_def_unit_type')
    """
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='parameter_def_val_type')
    """

    class Meta:
        managed = managed_tables
        db_table = 'parameter_def'

    def __str__(self):
        return "{}".format(self.description)


class Property(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='property_uuid')

    property_def = models.ForeignKey('PropertyDef',
                                     db_column='property_def_uuid',
                                     on_delete=models.DO_NOTHING,
                                     blank=True,
                                     null=True, related_name='property_property_def')
    #short_description = models.CharField(max_length=255,
    #                                     blank=True,
    #                                     null=True,
    #                                     db_column='short_description')
    property_val = ValField(blank=True,
                            null=True,
                            db_column='property_val')
    #unit_type = models.CharField(max_length=255,
    #                             blank=True,
    #                             null=True,
    #                             db_column='property_def_unit_type')
    property_class = models.CharField(max_length=64, choices=PROPERTY_CLASS_CHOICES)
    property_ref = RetUUIDField(blank=True, null=True)
    

    class Meta:
        managed = managed_tables
        db_table = 'property'

    def __str__(self):
        return "{} : {}".format(self.property_def, self.property_val)
    
"""
class PropertyX(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='property_x_uuid')
    material_uuid = models.ForeignKey('Property',
                                 db_column='material_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_x_material_uuid')
    property_uuid = models.ForeignKey('Property',
                                 db_column='property_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_x_property_uuid')
    
    class Meta:
        managed = managed_tables
        db_table = 'property_x'

    def __str__(self):
        return "{}".format(self.uuid)
"""

class PropertyDef(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='property_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    property_def_class = models.CharField(max_length=64, choices=PROPERTY_DEF_CLASS_CHOICES)
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
    unit_type = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='property_def_unit_type')

    class Meta:
        managed = managed_tables
        db_table = 'property_def'

    def __str__(self):
        return "{}".format(self.description)


class Status(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='status_uuid')
    description = models.CharField(max_length=255, null=True)
    
    class Meta:
        managed = managed_tables
        db_table = 'status'

    def __str__(self):
        return "{}".format(self.description)


class Tag(DateColumns, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='tag_uuid', editable=False)
    display_text = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)

    tag_type = models.ForeignKey('TagType', models.DO_NOTHING,
                                 db_column='tag_type_uuid',
                                 blank=True, null=True, related_name='tag_tag_type')
    type = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    type_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)

    class Meta:
        managed = managed_tables
        db_table = 'tag'

    def __str__(self):
        return "{}".format(self.display_text)


class TagAssign(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='tag_x_uuid')
    ref_tag = RetUUIDField(db_column='ref_tag_uuid')
    tag = models.ForeignKey('Tag', models.DO_NOTHING,
                            blank=True,
                            null=True,
                            db_column='tag_uuid', related_name='tag_assign_tag')

    class Meta:
        managed = managed_tables
        db_table = 'tag_assign'

    def __str__(self):
        return "{}".format(self.uuid)


class TagType(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='tag_type_uuid')
    type = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_tables
        db_table = 'tag_type'

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
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='udf_uuid')
    udf_def = models.ForeignKey('UdfDef', models.DO_NOTHING,
                            blank=True, null=True,
                            db_column='udf_def_uuid', related_name='udf_udf_def')
    description = models.CharField(max_length=255,  null=True)
    udf_value = ValField( db_column='udf_val')
    udf_val_edocument = models.ForeignKey('Edocument', models.DO_NOTHING,
                            blank=True, null=True,
                            db_column='udf_val_edocument_uuid', 
                            related_name='udf_udf_val_edocument')
    ref_udf = RetUUIDField(db_column='ref_udf_uuid')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = managed_tables
        db_table = 'udf'
    def __str__(self):
        return "{}".format(self.description)
    
class UdfX(models.Model):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='udf_x_uuid')
    ref_uuid = RetUUIDField(db_column='ref_udf_uuid')
    udf_uuid = models.ForeignKey('Udf', models.DO_NOTHING,
                         blank=True,
                         null=True,
                         editable=False,
                         db_column='udf_uuid',
                         related_name='udf_x_udf_uuid')
    
    class Meta:
        managed = managed_tables
        db_table = 'udf_x'    
    

class UdfDef(models.Model):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='udf_def_uuid')
    description = models.CharField(
        max_length=255,  null=True)
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='udf_def_val_type')
    #val_type_description = models.CharField(
    #    max_length=255, blank=True, null=True)
    unit = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_tables
        db_table = 'udf_def'

    def __str__(self):
        return "{}".format(self.description)

