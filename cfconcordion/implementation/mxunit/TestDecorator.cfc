<cfcomponent extends="mxunit.framework.TestDecorator" hint="MXUnit test decorator to stop Concordion fixture public methods being run as tests. The only test to run in CfConcordion is the base class test, 'RunConcordionTests'." output="false">

	<cffunction name="invokeTestMethod"	access="public" returntype="string" output="false" >
		<cfargument name="methodName" hint="the name of the method to invoke" type="string" required="Yes">
		<cfargument name="args" hint="Optional set of arguments" type="struct" required="No" default="#StructNew()#">

		<cfscript>
			var result = "";
			if( arguments.methodName EQ 'RunConcordionTests' ){
				result = getTarget().invokeTestMethod(arguments.methodName, arguments.args);
			}

			return result;
		</cfscript>
	</cffunction>

</cfcomponent>