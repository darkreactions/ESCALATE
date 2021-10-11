from core.models.view_tables import Edocument
from core.models.core_tables import TypeDef
from core.utilities.wf1_utils import generate_robot_file

#
def perovskite_demo(data, q1, experiment_copy_uuid, exp_name, exp_template,exp_number):
    robotfile_blob = generate_robot_file(q1,data,'Symyx_96_well_0003',exp_number)
    doc_type = TypeDef.objects.get(category='file', description='text')
    robotfile_edoc = Edocument(title=f'{experiment_copy_uuid}_{exp_name}_RobotInput.xls',
                               filename=f'{experiment_copy_uuid}_{exp_name}_RobotInput.xls',
                               ref_edocument_uuid=experiment_copy_uuid,
                               edocument=robotfile_blob.read(),
                               edoc_type_uuid=doc_type)
    robotfile_edoc.save()
    robotfile_uuid = robotfile_edoc.pk

    return robotfile_uuid, ''