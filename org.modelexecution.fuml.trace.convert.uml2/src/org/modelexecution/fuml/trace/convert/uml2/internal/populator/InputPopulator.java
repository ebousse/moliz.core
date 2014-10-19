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

import org.eclipse.uml2.uml.InputPin;
import org.modelexecution.fuml.trace.convert.IConversionResult;
import org.modelexecution.fuml.trace.convert.uml2.internal.IUML2TraceElementPopulator;
import org.modelexecution.fuml.trace.uml2.tracemodel.Input;
import org.modelexecution.fuml.trace.uml2.tracemodel.InputValue;

/**
 * @author Tanja Mayerhofer (mayerhofer@big.tuwien.ac.at)
 *
 */
public class InputPopulator implements IUML2TraceElementPopulator {

	/* (non-Javadoc)
	 * @see org.modelexecution.fuml.trace.convert.uml2.internal.IUML2TraceElementPopulator#populate(java.lang.Object, java.lang.Object, org.modelexecution.fuml.trace.uml2.convert.IConversionResult)
	 */
	@Override
	public void populate(Object umlTraceElement, Object fumlTraceElement,
			IConversionResult result, org.modelexecution.fuml.convert.IConversionResult modelConversionResult) {

		if(!(umlTraceElement instanceof Input) || !(fumlTraceElement instanceof org.modelexecution.fumldebug.core.trace.tracemodel.Input)) {
			return;
		}

		Input umlInput = (Input) umlTraceElement;
		org.modelexecution.fumldebug.core.trace.tracemodel.Input fumlInput = (org.modelexecution.fumldebug.core.trace.tracemodel.Input) fumlTraceElement;
		
		umlInput.setInputPin((InputPin)modelConversionResult.getInputObject(fumlInput.getInputPin()));
		
		for(org.modelexecution.fumldebug.core.trace.tracemodel.InputValue fumlInputValue : fumlInput.getInputValues()) {
			umlInput.getInputValues().add((InputValue)result.getOutputUMLTraceElement(fumlInputValue));
		}		
	}

}
