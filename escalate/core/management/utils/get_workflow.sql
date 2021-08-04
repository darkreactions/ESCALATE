select 
wf.description,
wf_parent.description as parent_description,
act.description as actor_description,
aa.experiment_descriptions,
aa.experiment_workflow_seq
from dev.workflow wf
left join dev.workflow wf_parent on (
	wf.parent_uuid = wf_parent.workflow_uuid
)
left join dev.workflow_type wftype on (
	wf.workflow_type_uuid = wftype.workflow_type_uuid
)
left join dev.actor act on (
	wf.actor_uuid = act.actor_uuid
)
left join (
	select 
	wf.workflow_uuid,
	string_agg(exp.description,',') as experiment_descriptions,
	string_agg(exp_work.experiment_workflow_seq::text,',') as experiment_workflow_seq
	from dev.workflow wf
	left join dev.experiment_workflow exp_work on (
		wf.workflow_uuid = exp_work.workflow_uuid
	) left join dev.experiment exp on (
		exp.experiment_uuid = exp_work.experiment_uuid
	)
	group by wf.workflow_uuid
) aa on (
	wf.workflow_uuid = aa.workflow_uuid
)