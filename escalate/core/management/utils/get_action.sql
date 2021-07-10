select
act.description,
act_def.description as action_def_description,
wf_act_set_p_def.description as parameter_def_description,
wf.description as workflow_description,
act.start_date,
act.end_date,
act.duration,
act.repeating,
calc_def.short_name as calculation_def_short_name
from
dev.action act 
left join dev.action_def act_def on (
	act.action_def_uuid = act_def.action_def_uuid
)
left join dev.workflow wf on (
	act.workflow_uuid = wf.workflow_uuid
)
left join dev.calculation_def calc_def on (
	act.calculation_def_uuid = calc_def.calculation_def_uuid
)
left join dev.workflow_action_set wf_act_set on (
	act.workflow_action_set_uuid = wf_act_set.workflow_action_set_uuid
)
left join dev.parameter_def wf_act_set_p_def on (
	wf_act_set.parameter_def_uuid = wf_act_set_p_def.parameter_def_uuid
)