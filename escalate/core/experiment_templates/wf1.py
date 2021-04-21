from core.models.view_tables import Edocument
from core.models.core_tables import TypeDef
from core.utilities.wf1_utils import generate_robot_file


def perovskite_demo(experiment_copy_uuid, exp_name):
    robotfile_blob = generate_robot_file()
    doc_type = TypeDef.objects.get(category='file', description='text')
    robotfile_edoc = Edocument(title=f'{experiment_copy_uuid}_LBL_RobotInput.xlsx',
                               filename=f'{experiment_copy_uuid}_LBL_RobotInput.xlsx',
                               ref_edocument_uuid=experiment_copy_uuid,
                               edocument=robotfile_blob.read(),
                               doc_type_uuid=doc_type)
    robotfile_edoc.save()
    robotfile_uuid = robotfile_edoc.pk

    return robotfile_uuid, ''
