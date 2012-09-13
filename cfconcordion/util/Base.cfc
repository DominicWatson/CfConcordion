<cfcomponent output="false">
	
	<!--- for java cfc proxying, all java objects should have toString() method --->
	<cffunction name="toString" access="public" returntype="string" output="false">
		<cfreturn getMetaData(this).name />
	</cffunction>

	<!--- utility methods --->
	<cffunction name="$throw" access="public" returntype="void" output="false" hint="I throw an error">
		<cfargument name="type"			type="string" required="false" default="CfConcordion.error" />
		<cfargument name="message"		type="string" required="false" />
		<cfargument name="detail"		type="string" required="false" />
		<cfargument name="errorCode"	type="string" required="false" />
		<cfargument name="extendedInfo"	type="string" required="false" />
		

		<cfthrow attributeCollection="#arguments#" />
	</cffunction>

	<cffunction name="$queryToArrayOfStructs" access="public" returntype="array" output="false">
		<cfargument name="qry" type="query" required="true" />

		<cfscript>
			var cols = ListToArray( arguments.qry.columnList );
			var row  = StructNew();
			var arr  = ArrayNew(1);
			var i    = "";
			var n    = "";

			for(i=1; i LTE arguments.qry.recordCount; i++){
				row  = StructNew();
				for(n=1; n LTE ArrayLen(cols); n++){
					row[cols[n]] = arguments.qry[cols[n]][i];
				}
				ArrayAppend(arr, row);
			}

			return arr;
		</cfscript>
	</cffunction>

	<cffunction name="$isRailo" access="public" returntype="boolean" output="false">
		<cfreturn StructKeyExists(server, 'railo') />
	</cffunction>
	
</cfcomponent>