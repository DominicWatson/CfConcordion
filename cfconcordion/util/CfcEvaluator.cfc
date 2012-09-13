<cfcomponent output="false" extends="Base">

<!--- PROPERTIES --->
	<cfscript>
		_cfc                = StructNew();
	</cfscript>

<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="component" type="any" required="true" />

		<cfscript>
			_setAndDecorateComponent( arguments.component );

			return this;
		</cfscript>
	</cffunction>

<!--- PUBLIC INTERFACE METHODS (see org.concordion.api.Evaluator java interface ) --->
	<cffunction name="getVariable" access="public" returntype="any" output="false">
		<cfargument name="variableName" type="string" required="true" />

		<cfscript>
			return _getComponent().$getVariable( arguments.variableName );
		</cfscript>
	</cffunction>

	<cffunction name="setVariable" access="public" returntype="void" output="false">
		<cfargument name="variableName" type="string" required="true" />
		<cfargument name="value" type="any" required="false" />

		<cfscript>
			_getComponent().$setVariable( argumentCollection = arguments );
		</cfscript>
	</cffunction>

	<cffunction name="evaluate" access="public" returntype="any" output="false">
		<cfargument name="expression" type="string" required="true" />

		<cfscript>
			var possible = StructNew();

			possible.result = _getComponent().$evaluate( arguments.expression );

			if(StructKeyExists(possible, 'result')){
				if(IsQuery(possible.result)){
					return $queryToArrayOfStructs( possible.result );
				}
				return possible.result;
			}

			return;
		</cfscript>
	</cffunction>


<!--- UTILITY METHODS AND ACCESSORS --->
	<cffunction name="_setAndDecorateComponent" access="private" returntype="any" output="false">
		<cfargument name="component" type="any" required="true" />

		<cfscript>
			_cfc = arguments.component;

			_cfc.$evaluate                        = this.$evaluate;
			_cfc.$setVariable                     = this.$setVariable;
			_cfc.$getVariable                     = this.$getVariable;
			_cfc.$fixConcordionVariableNamesForCf = this.$fixConcordionVariableNamesForCf;
			_cfc.$throw                           = this.$throw;
		</cfscript>
	</cffunction>

	<cffunction name="_getComponent" access="private" returntype="any" output="false">
		<cfreturn _cfc />
	</cffunction>

<!--- METHODS TO DECORATE TARGET COMPONENT WITH --->
	<cffunction name="$evaluate" access="public" returntype="any" output="false" hint="I will be attached to the target component (the target will be decorated with me)">
		<cfargument name="expression" type="string" required="true" />

		<cfscript>
			var result      = StructNew();
			var expr        = this.$fixConcordionVariableNamesForCf( arguments.expression );

			try {
				return evaluate( expr );

			} catch( "coldfusion.runtime.UndefinedVariableException" e ) {
				err = e;

				// trying turning the expression into a getter method when
				// just a variablename, i.e. SomeVar becomes getSomeVar()
				try {
					return evaluate( 'get' & expr & '()' );
				} catch( any e ){}

				rethrow;
			}
		</cfscript>
	</cffunction>

	<cffunction name="$getVariable" access="public" returntype="any" output="false">
		<cfargument name="variableName" type="string" required="true" />

		<cfscript>
			var varName = this.$fixConcordionVariableNamesForCf( arguments.variableName );

			if( StructkeyExists( variables, varName )) {
				return variables[varName];
			}
			return; // void
		</cfscript>
	</cffunction>

	<cffunction name="$setVariable" access="public" returntype="void" output="false">
		<cfargument name="variableName" type="string" required="true" />
		<cfargument name="value" type="any" required="false" />

		<cfscript>
			var varName = this.$fixConcordionVariableNamesForCf( arguments.variableName );

			// sometimes value can be VOID, check its here
			if(StructKeyExists(arguments, 'value')){

				// check variable name begins with '#' ($ after we have translated them)
				if(Left(varName, 1) NEQ '$'){
					this.$throw(message="Variable for concordion:set must start with ##. Change concordion:set=#arguments.variableName# to concordion:set=###arguments.variableName#.");
				}

				variables[varName] = arguments.value;
			}
		</cfscript>
	</cffunction>

	<cffunction name="$fixConcordionVariableNamesForCf" access="public" returntype="any" output="false" hint="I will be attached to the target component (the target will be decorated with me)">
		<cfargument name="expression" type="string" required="true" />

		<cfreturn Replace(arguments.expression, '##', '$', 'all') />
	</cffunction>

</cfcomponent>