/*
* Copyright (c) 2014 Vienna University of Technology.
* All rights reserved. This program and the accompanying materials are made 
* available under the terms of the Eclipse Public License v1.0 which accompanies 
* this distribution, and is available at http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Philip Langer - initial API
* Tanja Mayerhofer - implementation
*/
package org.modelexecution.fuml.trace.convert.uml2.internal.populator;

import org.modelexecution.fuml.trace.convert.IConversionResult;
import org.modelexecution.fuml.trace.convert.uml2.internal.IUML2TraceElementPopulator;
import org.modelexecution.fuml.trace.uml2.tracemodel.DecisionNodeExecution;
import org.modelexecution.fuml.trace.uml2.tracemodel.InputValue;

/**
 * @author Tanja Mayerhofer (mayerhofer@big.tuwien.ac.at)
 *
 */
public class DecisionNodeExecutionPopulator implements IUML2TraceElementPopulator {

	/* (non-Javadoc)
	 * @see org.modelexecution.fuml.trace.convert.uml2.internal.IUML2TraceElementPopulator#populate(java.lang.Object, java.lang.Object, org.modelexecution.fuml.trace.uml2.convert.IConversionResult)
	 */
	@Override
	public void populate(Object umlTraceElement, Object fumlTraceElement,
			IConversionResult result, org.modelexecution.fuml.convert.IConversionResult modelConversionResult) {

		if(!(umlTraceElement instanceof DecisionNodeExecution) || !(fumlTraceElement instanceof org.modelexecution.fumldebug.core.trace.tracemodel.DecisionNodeExecution)) {
			return;
		}

		DecisionNodeExecution umlDecisionNodeExecution = (DecisionNodeExecution) umlTraceElement;
		org.modelexecution.fumldebug.core.trace.tracemodel.DecisionNodeExecution fumlDecisionNodeExecution = (org.modelexecution.fumldebug.core.trace.tracemodel.DecisionNodeExecution) fumlTraceElement;
		
		umlDecisionNodeExecution.setDecisionInputValue((InputValue)result.getOutputUMLTraceElement(fumlDecisionNodeExecution.getDecisionInputValue()));
	}

}
