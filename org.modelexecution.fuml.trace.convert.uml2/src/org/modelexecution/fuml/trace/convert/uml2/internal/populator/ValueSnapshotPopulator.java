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
import org.modelexecution.fuml.trace.uml2.fuml.Semantics.Classes.Kernel.Value;
import org.modelexecution.fuml.trace.uml2.tracemodel.ValueInstance;
import org.modelexecution.fuml.trace.uml2.tracemodel.ValueSnapshot;

/**
 * @author Tanja Mayerhofer (mayerhofer@big.tuwien.ac.at)
 *
 */
public class ValueSnapshotPopulator implements IUML2TraceElementPopulator {

	/* (non-Javadoc)
	 * @see org.modelexecution.fuml.trace.convert.uml2.internal.IUML2TraceElementPopulator#populate(java.lang.Object, java.lang.Object, org.modelexecution.fuml.trace.uml2.convert.IConversionResult)
	 */
	@Override
	public void populate(Object umlTraceElement, Object fumlTraceElement,
			IConversionResult result, org.modelexecution.fuml.convert.IConversionResult modelConversionResult) {

		if(!(umlTraceElement instanceof ValueSnapshot) || !(fumlTraceElement instanceof org.modelexecution.fumldebug.core.trace.tracemodel.ValueSnapshot)) {
			return;
		}

		ValueSnapshot umlValueSnapshot = (ValueSnapshot) umlTraceElement;
		org.modelexecution.fumldebug.core.trace.tracemodel.ValueSnapshot fumlValueSnapshot = (org.modelexecution.fumldebug.core.trace.tracemodel.ValueSnapshot) fumlTraceElement;
		
		umlValueSnapshot.setValue((Value)result.getOutputUMLTraceElement(fumlValueSnapshot.getValue()));
		
		umlValueSnapshot.setValueInstance((ValueInstance)result.getOutputUMLTraceElement(fumlValueSnapshot.getValueInstance()));
		
	}

}
