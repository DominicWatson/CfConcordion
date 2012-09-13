<cfcomponent output="false">
	<cfscript>
		this.name                          = "CfConcordionTestingSuite" & hash(getCurrentTemplatePath());
		this.sessionManagement             = true;
		this.sessionTimeout                = createTimeSpan(0,0,30,0);
		this.setClientCookies              = true;

		variables.dir                      = GetDirectoryFromPath(getCurrentTemplatePath());

		this.mappings["/cfconcordion"]     = dir & '../cfconcordion/';
		this.mappings["/mxunit"]           = dir & 'mxunit/';
		this.mappings["/tests"]            = dir & 'tests/';

		request.cfconcordion_output_dir    = dir & 'output/';
	</cfscript>
</cfcomponent>