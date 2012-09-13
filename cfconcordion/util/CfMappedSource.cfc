<cfcomponent output="false" extends="Base">

<!--- PUBLIC INTERFACE METHODS (see org.concordion.api.Source java interface ) --->
	<cffunction name="createInputStream" access="public" returntype="any" output="false">
		<cfargument name="resource" type="any" required="true" />

		<cfscript>
			var filePath        = _getFilePathFromConcordionResourceObject( arguments.resource );
			var javaInputStream = CreateObject('java', 'java.io.FileInputStream').init( filePath );

			return javaInputStream;
		</cfscript>
	</cffunction>

	<cffunction name="canFind" access="public" returntype="boolean" output="false">
		<cfargument name="resource" type="any" required="true" />

		<cfscript>
			return FileExists( _getFilePathFromConcordionResourceObject( arguments.resource ) );
		</cfscript>
	</cffunction>

<!--- PRIVATE UTILITY --->
	<cffunction name="_getFilePathFromConcordionResourceObject" access="private" returntype="any" output="false">
		<cfargument name="resource" type="any" required="true" />
		<!--- hint, the path will be set by our CfMappedSource component and will a mapped path, i.e. /cfmapping/path/to/resource --->
		<!--- @todo, throw friendly error when file does not exist --->
		<cfreturn ExpandPath( resource.getPath() ) />
	</cffunction>
</cfcomponent>