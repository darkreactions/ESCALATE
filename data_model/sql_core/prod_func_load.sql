/*
Name:					load_edocuments (p_actor_uuid uuid)
Parameters:		p_actor_uuid = identifier (uuid) of the actor owning this edocument
Returns:			boolean T or F
Author:				G. Cattabriga
Date:					2020.04.07
Description:	loads edocuments into the load table 
Notes:				
							
Example:			select load_edocuments((select actor_uuid from actor where description = 'Ian Pendleton'));
*/