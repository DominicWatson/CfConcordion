<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="cfconcordion.implementation.mxunit.TestDecorator" output="false">

	<cffunction name="RunConcordionTests" access="public" returntype="void" output="false">
		<cfscript>
			var concordion    = CreateObject('component', 'cfconcordion.CfConcordion').init();
			var result        = concordion.process( this );
			var resultMessage = "Concordion test ran with #result.getExceptionCount()# exceptions, #result.getFailureCount()# failures and #result.getSuccessCount()# successes.";
			var failed        = result.getExceptionCount() OR result.getFailureCount();

			super.debug( resultMessage );
			super.assertFalse( failed, resultMessage );
		</cfscript>
	</cffunction>

</cfcomponent>