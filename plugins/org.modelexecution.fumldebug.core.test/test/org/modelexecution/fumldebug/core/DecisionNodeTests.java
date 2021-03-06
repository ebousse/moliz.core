/*
 * Copyright (c) 2012 Vienna University of Technology.
 * All rights reserved. This program and the accompanying materials are made 
 * available under the terms of the Eclipse Public License v1.0 which accompanies 
 * this distribution, and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Tanja Mayerhofer - initial API and implementation
 */

package org.modelexecution.fumldebug.core;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.modelexecution.fumldebug.core.event.ActivityEntryEvent;
import org.modelexecution.fumldebug.core.event.ActivityExitEvent;
import org.modelexecution.fumldebug.core.event.Event;
import org.modelexecution.fumldebug.core.event.ExtensionalValueEvent;
import org.modelexecution.fumldebug.core.event.SuspendEvent;
import org.modelexecution.fumldebug.core.util.ActivityFactory;

import fUML.Semantics.Classes.Kernel.BooleanValue;
import fUML.Semantics.Classes.Kernel.ExtensionalValueList;
import fUML.Semantics.Classes.Kernel.IntegerValue;
import fUML.Semantics.Classes.Kernel.Object_;
import fUML.Semantics.Classes.Kernel.StringValue;
import fUML.Semantics.CommonBehaviors.BasicBehaviors.ParameterValueList;
import fUML.Syntax.Actions.IntermediateActions.ValueSpecificationAction;
import fUML.Syntax.Activities.IntermediateActivities.Activity;
import fUML.Syntax.Activities.IntermediateActivities.ActivityParameterNode;
import fUML.Syntax.Activities.IntermediateActivities.DecisionNode;
import fUML.Syntax.Classes.Kernel.Parameter;
import fUML.Syntax.Classes.Kernel.ParameterDirectionKind;
import fUML.Syntax.CommonBehaviors.BasicBehaviors.Behavior;

/**
 * @author Tanja Mayerhofer
 *
 */
public class DecisionNodeTests extends MolizTest implements ExecutionEventListener{

	private List<Event> eventlist = new ArrayList<Event>();
	private List<ExtensionalValueList> extensionalValueLists = new ArrayList<ExtensionalValueList>();
	
	public DecisionNodeTests() {
		ExecutionContext.getInstance().reset();
		ExecutionContext.getInstance().addEventListener(this);		
	}
	
	/**
	 * @throws java.lang.Exception
	 */
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception {
		eventlist = new ArrayList<Event>();
		extensionalValueLists = new ArrayList<ExtensionalValueList>();
		ExecutionContext executionContext = ExecutionContext.getInstance();
		executionContext.reset();
		executionContext.addEventListener(this);
		registerPrimitiveBehaviors(executionContext);
	}

	/**
	 * @throws java.lang.Exception
	 */
	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testDecision1_WithBehaviorWithInputFlow() {
		Activity activity = ActivityFactory.createActivity("Activity testDecision1_WithBehaviorWithInputFlow");
		ValueSpecificationAction specify1 = ActivityFactory.createValueSpecificationAction(activity, "specify 1", 1);
		ValueSpecificationAction specify2 = ActivityFactory.createValueSpecificationAction(activity, "specify 2", 2);
		DecisionNode decision = ActivityFactory.createDecisionNode(activity, "decision");
		Behavior less = ExecutionContext.getInstance().getOpaqueBehavior("less");
		decision.setDecisionInput(less);
		Parameter outparam = ActivityFactory.createParameter(activity, "out", ParameterDirectionKind.out);
		ActivityParameterNode outparamnode = ActivityFactory.createActivityParameterNode(activity, "out", outparam); 
		ActivityFactory.createObjectFlow(activity, specify1.result, decision);
		ActivityFactory.createDecisionInputFlow(activity, specify2.result, decision);
		ActivityFactory.createObjectFlow(activity, decision, outparamnode, true);		
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(1, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(0)).value);
	}
	
	@Test
	public void testDecision2_WithBehaviorWithInputFlow() {
		Activity activity = ActivityFactory.createActivity("Activity testDecision2_WithBehaviorWithInputFlow");
		ValueSpecificationAction specify1 = ActivityFactory.createValueSpecificationAction(activity, "specify 1", 1);
		ValueSpecificationAction specify2 = ActivityFactory.createValueSpecificationAction(activity, "specify 2", 2);
		DecisionNode decision = ActivityFactory.createDecisionNode(activity, "decision");
		Behavior less = ExecutionContext.getInstance().getOpaqueBehavior("less");
		decision.setDecisionInput(less);
		Parameter outparam = ActivityFactory.createParameter(activity, "out", ParameterDirectionKind.out);
		ActivityParameterNode outparamnode = ActivityFactory.createActivityParameterNode(activity, "out", outparam); 
		ActivityFactory.createObjectFlow(activity, specify1.result, decision);
		ActivityFactory.createDecisionInputFlow(activity, specify2.result, decision);
		ActivityFactory.createObjectFlow(activity, decision, outparamnode, false);		
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(0, outvalues.get(0).values.size());
	}
	
	@Test
	public void testDecision3() {
		Activity activity = ActivityFactory.createActivity("Activity testDecision3");
		ValueSpecificationAction specifytrue = ActivityFactory.createValueSpecificationAction(activity, "specify true", true);
		DecisionNode decision = ActivityFactory.createDecisionNode(activity, "decision");
		Parameter outparam = ActivityFactory.createParameter(activity, "out", ParameterDirectionKind.out);
		ActivityParameterNode outparamnode = ActivityFactory.createActivityParameterNode(activity, "out", outparam); 
		ActivityFactory.createObjectFlow(activity, specifytrue.result, decision);
		ActivityFactory.createObjectFlow(activity, decision, outparamnode, true);		
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(1, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof BooleanValue);
		assertEquals(true, ((BooleanValue)outvalues.get(0).values.get(0)).value);
	}
	
	@Test
	public void testDecision4_WithInputFlow() {
		Activity activity = ActivityFactory.createActivity("Activity testDecision4_WithInputFlow");
		ValueSpecificationAction specifylala = ActivityFactory.createValueSpecificationAction(activity, "specify lala", "lala");
		ValueSpecificationAction specifytrue = ActivityFactory.createValueSpecificationAction(activity, "specify true", true);
		DecisionNode decision = ActivityFactory.createDecisionNode(activity, "decision");
		Parameter outparam = ActivityFactory.createParameter(activity, "out", ParameterDirectionKind.out);
		ActivityParameterNode outparamnode = ActivityFactory.createActivityParameterNode(activity, "out", outparam); 
		ActivityFactory.createObjectFlow(activity, specifylala.result, decision);
		ActivityFactory.createDecisionInputFlow(activity, specifytrue.result, decision);
		ActivityFactory.createObjectFlow(activity, decision, outparamnode, true);		
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(1, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof StringValue);
		assertEquals("lala", ((StringValue)outvalues.get(0).values.get(0)).value);
	}
	
	@Test
	public void testDecision5_NoInputNoBehavior() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity1 testactivity = factory.new DecisionNodeTestActivity1();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		assertEquals(6, eventlist.size());
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(1, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(0)).value);
	}
	
	@Test
	public void testDecision6_InputNoBehavior() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity2 testactivity = factory.new DecisionNodeTestActivity2();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		assertEquals(8, eventlist.size());
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(1, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(0)).value);
	}
	
	@Test
	public void testDecision7_InputBehavior() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity3 testactivity = factory.new DecisionNodeTestActivity3();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		assertEquals(8, eventlist.size());
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(1, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(0)).value);
	}

	@Test
	public void testDecision8_MultipleInputTokens() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity5 testactivity = factory.new DecisionNodeTestActivity5();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		assertEquals(18, eventlist.size());
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(3, outvalues.get(0).values.size());
		for(int i=0;i<3;++i) {
			assertTrue(outvalues.get(0).values.get(i) instanceof IntegerValue);
			assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(i)).value);
		}
	}
	
	@Test
	public void testDecision9_MultipleInputTokens2() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity6 testactivity = factory.new DecisionNodeTestActivity6();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		assertEquals(14, eventlist.size());
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(1, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(0, ((IntegerValue)outvalues.get(0).values.get(0)).value);
	}
	
	@Test
	public void testDecision10_MultipleInputTokens3() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity7 testactivity = factory.new DecisionNodeTestActivity7();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().execute(activity, null, null);
		
		assertEquals(20, eventlist.size());
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(2, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(0, ((IntegerValue)outvalues.get(0).values.get(0)).value);
		assertTrue(outvalues.get(0).values.get(1) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(1)).value);
	}
	
	@Test
	public void testDecision11_MultipleInputTokens4() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity7 testactivity = factory.new DecisionNodeTestActivity7();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().executeStepwise(activity, null, null);
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs0);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs1);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
				
		assertEquals(22, eventlist.size());
		
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(2, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(0, ((IntegerValue)outvalues.get(0).values.get(0)).value);
		assertTrue(outvalues.get(0).values.get(1) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(1)).value);
	}
	
	@Test
	public void testDecision12_MultipleInputTokens5() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity7 testactivity = factory.new DecisionNodeTestActivity7();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().executeStepwise(activity, null, null);
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs0);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs1);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
				
		assertEquals(22, eventlist.size());
		
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(2, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(0, ((IntegerValue)outvalues.get(0).values.get(0)).value);
		assertTrue(outvalues.get(0).values.get(1) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(1)).value);
	}
	
	@Test
	public void testDecision13_MultipleInputTokens6() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity7 testactivity = factory.new DecisionNodeTestActivity7();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().executeStepwise(activity, null, null);
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs0);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs1);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
				
		assertEquals(22, eventlist.size());
		
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(2, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(0, ((IntegerValue)outvalues.get(0).values.get(0)).value);
		assertTrue(outvalues.get(0).values.get(1) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(1)).value);
	}
	
	@Test
	public void testDecision14_MultipleInputTokens7() {
		TestActivityFactory factory = new TestActivityFactory();
		TestActivityFactory.DecisionNodeTestActivity7 testactivity = factory.new DecisionNodeTestActivity7();
		Activity activity = testactivity.activity;
		
		ExecutionContext.getInstance().executeStepwise(activity, null, null);
		int executionID = ((ActivityEntryEvent)eventlist.get(0)).getActivityExecutionID();
		
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs0);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs1);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.vs2);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.merge);
		ExecutionContext.getInstance().nextStep(executionID, testactivity.decision);
				
		assertEquals(22, eventlist.size());
		
		ParameterValueList outvalues = ExecutionContext.getInstance().getActivityOutput(executionID);
		assertEquals(1, outvalues.size());
		assertEquals(2, outvalues.get(0).values.size());
		assertTrue(outvalues.get(0).values.get(0) instanceof IntegerValue);
		assertEquals(0, ((IntegerValue)outvalues.get(0).values.get(0)).value);
		assertTrue(outvalues.get(0).values.get(1) instanceof IntegerValue);
		assertEquals(1, ((IntegerValue)outvalues.get(0).values.get(1)).value);
	}

	@Override
	public void notify(Event event) {
		if(!(event instanceof ExtensionalValueEvent) && !(event instanceof SuspendEvent)) {
			eventlist.add(event);
			System.err.println(event);
		}
		
		if(event instanceof SuspendEvent || event instanceof ActivityExitEvent) {
			ExtensionalValueList list = new ExtensionalValueList();
			for(int i=0;i<ExecutionContext.getInstance().getExtensionalValues().size();++i) {
				if(ExecutionContext.getInstance().getExtensionalValues().get(i).getClass() == Object_.class) {
					//list.add(ExecutionContext.getInstance().getExtensionalValues().get(i));
					list.add(copyObject((Object_)ExecutionContext.getInstance().getExtensionalValues().get(i)));
				}
			}
			extensionalValueLists.add(list);
		}
	}
	
}
