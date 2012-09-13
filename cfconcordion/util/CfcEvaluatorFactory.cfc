<cfcomponent output="false" extends="Base">

<!--- PROPERTIES --->
	<cfscript>
		_javaLoader   = "";
		_proxyFactory = "";
	</cfscript>

<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="javaLoader" type="any" required="true" />

		<cfscript>
			_setJavaLoader( arguments.javaLoader );
			_setProxyFactory( _getJavaLoader().create("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy") );

			return this;
		</cfscript>
	</cffunction>

<!--- PUBLIC INTERFACE METHODS (see org.concordion.api.EvaluatorFactory java interface ) --->
	<cffunction name="createEvaluator" access="public" returntype="any" output="false">
		<cfargument name="component" type="any" required="true" />

		<cfscript>
			var evaluatorCfc = CreateObject('component', 'CfcEvaluator').init( arguments.component );

			return _getProxyFactory().createInstance( evaluatorCfc, ["org.concordion.api.Evaluator"] );
		</cfscript>
	</cffunction>

<!--- PRIVATE ACCESSORS --->
	<cffunction name="_setJavaLoader" access="private" returntype="void" output="false">
		<cfargument name="jl" type="any" required="true" />

		<cfset _javaLoader = arguments.jl />
	</cffunction>
	<cffunction name="_getJavaLoader" access="private" returntype="any" output="false">
		<cfreturn _javaLoader />
	</cffunction>

	<cffunction name="_setProxyFactory" access="private" returntype="void" output="false">
		<cfargument name="proxyFactory" type="any" required="true" />

		<cfset _proxyFactory = arguments.proxyFactory />
	</cffunction>
	<cffunction name="_getProxyFactory" access="private" returntype="any" output="false">
		<cfreturn _proxyFactory />
	</cffunction>

</cfcomponent>