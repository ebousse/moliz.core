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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.modelexecution.fumldebug.core.ExecutionContext;
import org.modelexecution.fumldebug.core.ExecutionEventListener;
import org.modelexecution.fumldebug.core.ExecutionEventProvider;
import org.modelexecution.fumldebug.core.event.ActivityEntryEvent;
import org.modelexecution.fumldebug.core.event.ActivityExitEvent;
import org.modelexecution.fumldebug.core.event.ActivityNodeEntryEvent;
import org.modelexecution.fumldebug.core.event.ActivityNodeExitEvent;
import org.modelexecution.fumldebug.core.event.BreakpointEvent;
import org.modelexecution.fumldebug.core.event.Event;
import org.modelexecution.fumldebug.core.event.ExtensionalValueEvent;
import org.modelexecution.fumldebug.core.event.ExtensionalValueEventType;
import org.modelexecution.fumldebug.core.event.FeatureValueEvent;
import org.modelexecution.fumldebug.core.event.SuspendEvent;
import org.modelexecution.fumldebug.core.event.impl.ActivityEntryEventImpl;
import org.modelexecution.fumldebug.core.event.impl.ActivityExitEventImpl;
import org.modelexecution.fumldebug.core.event.impl.ActivityNodeEntryEventImpl;
import org.modelexecution.fumldebug.core.event.impl.ActivityNodeExitEventImpl;
import org.modelexecution.fumldebug.core.event.impl.BreakpointEventImpl;
import org.modelexecution.fumldebug.core.event.impl.ExtensionalValueEventImpl;
import org.modelexecution.fumldebug.core.event.impl.FeatureValueEventImpl;
import org.modelexecution.fumldebug.core.event.impl.SuspendEventImpl;
import org.modelexecution.fumldebug.core.trace.tracemodel.ObjectTokenInstance;
import org.modelexecution.fumldebug.core.trace.tracemodel.ParameterInput;
import org.modelexecution.fumldebug.core.trace.tracemodel.ParameterOutput;
import org.modelexecution.fumldebug.core.trace.tracemodel.Trace;
import org.modelexecution.fumldebug.core.trace.tracemodel.ValueInstance;
import org.modelexecution.fumldebug.core.trace.tracemodel.impl.ObjectTokenInstanceImpl;
import org.modelexecution.fumldebug.core.trace.tracemodel.impl.ParameterOutputImpl;
import org.modelexecution.fumldebug.core.trace.tracemodel.impl.UserParameterInputImpl;
import org.modelexecution.fumldebug.core.trace.tracemodel.impl.ValueInstanceImpl;

import fUML.Debug;
import fUML.Semantics.Actions.BasicActions.ActionActivation;
import fUML.Semantics.Actions.BasicActions.CallActionActivation;
import fUML.Semantics.Actions.BasicActions.CallBehaviorActionActivation;
import fUML.Semantics.Actions.BasicActions.PinActivation;
import fUML.Semantics.Actions.CompleteActions.ReclassifyObjectActionActivation;
import fUML.Semantics.Actions.IntermediateActions.AddStructuralFeatureValueActionActivation;
import fUML.Semantics.Actions.IntermediateActions.ReadStructuralFeatureActionActivation;
import fUML.Semantics.Actions.IntermediateActions.RemoveStructuralFeatureValueActionActivation;
import fUML.Semantics.Actions.IntermediateActions.StructuralFeatureActionActivation;
import fUML.Semantics.Activities.IntermediateActivities.ActivityExecution;
import fUML.Semantics.Activities.IntermediateActivities.ActivityFinalNodeActivation;
import fUML.Semantics.Activities.IntermediateActivities.ActivityNodeActivation;
import fUML.Semantics.Activities.IntermediateActivities.ActivityNodeActivationList;
import fUML.Semantics.Activities.IntermediateActivities.ActivityParameterNodeActivation;
import fUML.Semantics.Activities.IntermediateActivities.ActivityParameterNodeActivationList;
import fUML.Semantics.Activities.IntermediateActivities.ObjectNodeActivation;
import fUML.Semantics.Activities.IntermediateActivities.ObjectToken;
import fUML.Semantics.Activities.IntermediateActivities.Token;
import fUML.Semantics.Activities.IntermediateActivities.TokenList;
import fUML.Semantics.Activities.IntermediateActivities.ControlNodeActivation;
import fUML.Semantics.Activities.IntermediateActivities.DecisionNodeActivation;
import fUML.Semantics.Activities.IntermediateActivities.ActivityEdgeInstance;
import fUML.Semantics.Activities.IntermediateActivities.ActivityNodeActivationGroup;
import fUML.Semantics.Classes.Kernel.CompoundValue;
import fUML.Semantics.Classes.Kernel.FeatureValue;
import fUML.Semantics.Classes.Kernel.FeatureValueList;
import fUML.Semantics.Classes.Kernel.Link;
import fUML.Semantics.Classes.Kernel.Object_;
import fUML.Semantics.Classes.Kernel.ExtensionalValue;
import fUML.Semantics.Classes.Kernel.ExtensionalValueList;
import fUML.Semantics.Classes.Kernel.Reference;
import fUML.Semantics.Classes.Kernel.ValueList;
import fUML.Semantics.Classes.Kernel.Value;
import fUML.Semantics.Loci.LociL1.Executor;
import fUML.Semantics.Loci.LociL1.Locus;
import fUML.Semantics.Loci.LociL1.SemanticVisitor;
import fUML.Semantics.CommonBehaviors.BasicBehaviors.OpaqueBehaviorExecution;
import fUML.Semantics.CommonBehaviors.BasicBehaviors.ParameterValue;
import fUML.Semantics.CommonBehaviors.BasicBehaviors.ParameterValueList;
import fUML.Semantics.CommonBehaviors.BasicBehaviors.Execution;

import fUML.Syntax.Classes.Kernel.Class_;
import fUML.Syntax.Classes.Kernel.Class_List;
import fUML.Syntax.Classes.Kernel.Element;
import fUML.Syntax.Classes.Kernel.Parameter;
import fUML.Syntax.Classes.Kernel.Property;
import fUML.Syntax.Classes.Kernel.StructuralFeature;
import fUML.Syntax.CommonBehaviors.BasicBehaviors.Behavior;
import fUML.Syntax.Actions.BasicActions.CallAction;
import fUML.Syntax.Actions.BasicActions.OutputPin;
import fUML.Syntax.Actions.IntermediateActions.StructuralFeatureAction;
import fUML.Syntax.Activities.IntermediateActivities.Activity;
import fUML.Syntax.Activities.IntermediateActivities.ActivityNode;
import fUML.Syntax.Activities.IntermediateActivities.ActivityParameterNode;

public aspect EventEmitterAspect implements ExecutionEventListener {
 
	private ExecutionEventProvider eventprovider = null;
	private List<Event> eventlist = new ArrayList<Event>();
	
	public EventEmitterAspect()	{
		eventprovider = ExecutionContext.getInstance().getExecutionEventProvider();
		eventprovider.addEventListener(this);		
	}	
	
	private pointcut activityExecution(ActivityExecution execution) : call (void Execution.execute()) && withincode(ParameterValueList Executor.execute(Behavior, Object_, ParameterValueList)) && target(execution);
	
	private pointcut inStepwiseExecutionMode() : cflow(execution(void ExecutionContext.executeStepwise(Behavior, Object_, ParameterValueList)));
	
	private pointcut activityExecutionInStepwiseExecutionMode(ActivityExecution execution) :  activityExecution(execution) && inStepwiseExecutionMode();
	
	private pointcut inExecutionMode() : cflow(execution(void ExecutionContext.execute(Behavior, Object_, ParameterValueList)));
		
	private pointcut activityExecutionInExecutionMode(ActivityExecution execution) :  activityExecution(execution) && inExecutionMode();
			
	/**
	 * Handling of ActivityEntryEvent in stepwise execution mode
	 * @param execution Execution object of the executed behavior
	 */
	before(ActivityExecution execution) : activityExecutionInStepwiseExecutionMode(execution) {
		handleNewActivityExecution(execution, null, null);
	}	
	
	/**
	 * Handling of ActivityEntryEvent in execution mode
	 * @param execution Execution object of the executed behavior
	 */
	before(ActivityExecution execution) : activityExecutionInExecutionMode(execution) {
		ExecutionContext.getInstance().setExecutionInResumeMode(execution, true);
		handleNewActivityExecution(execution, null, null);
	}
	
	/**
	 * Handling of first resume() call in case of execution mode
	 * @param execution
	 */
	after(ActivityExecution execution) : activityExecutionInExecutionMode(execution) {
		boolean hasEnabledNodes = ExecutionContext.getInstance().hasEnabledNodesIncludingCallees(execution);
		if(hasEnabledNodes) {
			ExecutionContext.getInstance().resume(execution.hashCode());
		}
	}
		
	/**
	 * Execution of the method ActionActivation.fire(TokenList)
	 * @param activation Activation object of the Action
	 */
	private pointcut fireActionActivationExecution(ActionActivation activation) : execution (void ActionActivation.fire(TokenList)) && target(activation);
	
	/**
	 * Handling of ActivityNodeEntryEvent for Actions
	 * @param activation Activation object of the 
	 */
	before(ActionActivation activation) : fireActionActivationExecution(activation) {
		handleActivityNodeEntry(activation);
	}
	
	/**
	 * Call of the method ActionActivation.sendOffers() within ActionActivation.fire(TokenList)
	 * @param activation Activation object of the Action for which sendOffers() is called 
	 */
	private pointcut fireActionActivationSendOffers(ActionActivation activation) : call(void ActionActivation.sendOffers()) && target(activation) && withincode(void ActionActivation.fire(TokenList));
	
	/**
	 * Handling of ActivityNodeExitEvent for Actions
	 * @param activation Activation object of the Action
	 */
	before(ActivityNodeActivation activation) : fireActionActivationSendOffers(activation) {	
		if(activation instanceof CallActionActivation) {
			if(((CallActionActivation)activation).callExecutions.size() > 0) {
				return;
			}
		}
		handleActivityNodeExit(activation);
	}
		
	/**
	 * Execution of the method ControlNodeActivation.fire(TokenList)
	 * @param activation Activation object of the ControlNode for which fire(TokenList) is called
	 */
	private pointcut controlNodeFire(ControlNodeActivation activation) : execution (void ControlNodeActivation.fire(TokenList)) && target(activation);
	
	/**
	 * Handling of ActivityNodeEntryEvent for ControlNodes
	 * @param activation Activation object of the ControlNode
	 */
	before(ControlNodeActivation activation) : controlNodeFire(activation) {
		if(activation.node==null) {
			//anonymous fork node
			return;
		}						
		handleActivityNodeEntry(activation);
	}
	
	/**
	 * Execution of the method ActivityFinalNodeActivation.fire(TokenList)
	 * @param activation Activation object of the ActivityFinalNode
	 */
	private pointcut activityFinalNodeFire(ActivityFinalNodeActivation activation) : execution (void ActivityFinalNodeActivation.fire(TokenList)) && target(activation);
	
	/**
	 * Handling of ActivityNodeExitEvent for ActivityFinalNodeActivation
	 * @param activation activation object of the ActivityFinalNode
	 */
	after(ActivityFinalNodeActivation activation) : activityFinalNodeFire(activation) {
		handleActivityNodeExit(activation);
	}
	
	/**
	 * Call of ActivityNodeActivation.sendOffers(TokenList) within ControlNodeActivation.fire(TokenList)
	 * @param activation Activation object for which sendOffers(TokenList) is called
	 */
	private pointcut controlNodeFireSendOffers(ControlNodeActivation activation) : call(void ActivityNodeActivation.sendOffers(TokenList)) && target(activation) && withincode(void ControlNodeActivation.fire(TokenList));
	
	/**
	 * Handling of ActivityNodeExitEvent for MergeNode, InitialNode, ForkNode, JoinNode
	 * @param activation Activation object of the MergeNode, InitialNode, ForkNode, or JoinNode
	 */
	before(ControlNodeActivation activation) : controlNodeFireSendOffers(activation) {
		if(activation.node==null) {
			//anonymous fork node
			return;
		}
		handleActivityNodeExit(activation);
	}
		
	/**
	 * Handling of ActivityNodeExitEvent for DecisionNode if no
	 * outgoing edge exists or if no guard of any outgoing edge
	 * evaluates to true
	 * @param activation
	 */	
	private pointcut decisionNodeFireExecution(DecisionNodeActivation activation) : execution (void DecisionNodeActivation.fire(TokenList)) && target(activation);
	
	after(DecisionNodeActivation activation) : decisionNodeFireExecution(activation) {		
		int lastexitindex = -1;
		int lastentryindex = -1;
		
		for(int i=0;i<eventlist.size();++i) {
			int index = eventlist.size()-1-i;
			Event e = eventlist.get(index);
			if(e instanceof ActivityNodeExitEvent) {
				if(((ActivityNodeExitEvent)e).getNode() == activation.node && lastexitindex == -1) {
					lastexitindex = index;
				}
			} else if (e instanceof ActivityNodeEntryEvent){
				if(((ActivityNodeEntryEvent)e).getNode() == activation.node && lastentryindex == -1) {
					lastentryindex = index;
				}				
			}
		}
		
		if(lastexitindex == -1 || lastentryindex > lastexitindex) {
			handleActivityNodeExit(activation);
		}
	}
	
	/**
	 * Handling of ActivityNodeExitEvent for DecisionNode if the guard of 
	 * an outgoing edge evaluated to true
	 * @param activation Activation object of the DecisionNode
	 */
	private pointcut decisionNodeFireCallsSendOffer(DecisionNodeActivation activation) : call (void ActivityEdgeInstance.sendOffer(TokenList)) && withincode(void DecisionNodeActivation.fire(TokenList)) && this(activation);
	
	before(DecisionNodeActivation activation) : decisionNodeFireCallsSendOffer(activation) {
		/*
		 * This may occur more than once because ActivityEdgeInstance.sendOffer(TokenList) 
		 * is called in a loop in DecisionNodeActivation.fire(TokenList)
		 */	
		handleActivityNodeExit(activation);
	}
		
	public void notify(Event event) {
		eventlist.add(event);
	}
		
	/**
	 * Call of Object_.destroy() within Executor.execute(*)
	 * @param o Object_ for which destroy() is called
	 */
	private pointcut debugExecutorDestroy(Object_ o) : call (void Object_.destroy()) && withincode(ParameterValueList Executor.execute(Behavior, Object_, ParameterValueList)) && target(o);
	
	/**
	 * Prevents the method Executor.execute() from destroying the ActivityExecution 
	 * This is done after the execution of the Activity has finished see {@link #handleEndOfActivityExecution(ActivityExecution)}
	 * @param o
	 */
	void around(Object_ o) : debugExecutorDestroy(o) {
		
	}
	
	private pointcut debugCallBehaviorActionActivationDestroy(Object_ o, CallActionActivation activation) : call (void Object_.destroy()) && withincode(void CallActionActivation.doAction()) && this(activation) && target(o);	
	
	/**
	 * Prevents the method CallActionActivation.doAction() from destroying the Execution of the called Activity
	 * This is done when the execution of the called Activity is finished see {@link #handleEndOfActivityExecution(ActivityExecution)}
	 * @param o Execution that should be destroyed
	 * @param activation Activation of the CallAction
	 */
	void around(Object o, CallActionActivation activation) : debugCallBehaviorActionActivationDestroy(o, activation) {
		if(callsOpaqueBehaviorExecution(activation)) {
			proceed(o, activation);
		}
	}

	private pointcut debugRemoveCallExecution(CallActionActivation activation) : call (void CallActionActivation.removeCallExecution(Execution)) && withincode(void CallActionActivation.doAction()) && this(activation);
	
	/**
	 * Prevents the method CallActionActivation.removeCallExecution from removing the
	 * CallExecution within CallActionActivation.doAction()
	 * This is done when the execution of the called Activity finished see {@link #handleEndOfActivityExecution(ActivityExecution)}
	 * @param activation
	 */
	void around(CallActionActivation activation) : debugRemoveCallExecution(activation) {
		if(callsOpaqueBehaviorExecution(activation)) {
			proceed(activation);
		}
	}
	
	private pointcut callBehaviorActionSendsOffers(CallBehaviorActionActivation activation) : call (void ActionActivation.sendOffers()) && target(activation) && withincode(void ActionActivation.fire(TokenList));
	
	/**
	 * Prevents the method CallBehaviorActionActivation.fire() from sending offers (if an Activity was called)
	 * This is done when the execution of the called Activity is finished see {@link #handleEndOfActivityExecution(ActivityExecution)}
	 */
	void around(CallBehaviorActionActivation activation) : callBehaviorActionSendsOffers(activation) {
		if(activation.callExecutions.size()==0) {
			// If an OpaqueBehaviorExecution was called, this Execution was already removed in CallActionActivation.doAction()
			proceed(activation);
		}
	}
	
	private pointcut callBehaviorActionCallIsReady(CallBehaviorActionActivation activation) : call (boolean ActionActivation.isReady()) && target(activation) && withincode(void ActionActivation.fire(TokenList));
	
	/**
	 * Ensures that the do-while loop in the Action.fire() method is not called
	 * for a CallBehaviorActionActivation that calls an Activity by returning false 
	 * for CallBehaviorActionActiviation.fire()
	 * After the execution of the called Activity, is is checked if the CallBehaviorAction
	 * can be executed again see {@link #handleEndOfActivityExecution(ActivityExecution)}
	 * @return false
	 */
	boolean around(CallBehaviorActionActivation activation) : callBehaviorActionCallIsReady(activation) {
		if(activation.callExecutions.size()==0) {
			// If an OpaqueBehaviorExecution was called, this Execution was already removed in CallActionActivation.doAction()
			return proceed(activation);
		} else {
			return false;
		}
	}
	
	private boolean callsOpaqueBehaviorExecution(CallActionActivation activation) {
		if(activation.callExecutions.get(activation.callExecutions.size()-1) instanceof OpaqueBehaviorExecution) {
			return true;
		}
		return false;
	}
	
	/**
	 * Call of ActivityNodeActivation.fire(TokenList) within void ActivityNodeActivation.receiveOffer() 
	 * in the execution flow of ActivityNodeActivationGroup.run(ActivityNodeActivationList)
	 * i.e., call of ActivityNodeActivation.fire(TokenList) of the initial enabled nodes  
	 * @param activation Activation object of the ActivityNode for which fire(TokenList) is called
	 * @param tokens Tokens which are the parameters for ActivityNodeActivation.fire(TokenList)
	 */
	private pointcut debugActivityNodeFiresInitialEnabledNodes(ActivityNodeActivation activation, TokenList tokens) : call (void ActivityNodeActivation.fire(TokenList)) && withincode(void ActivityNodeActivation.receiveOffer()) && cflow(execution(void ActivityNodeActivationGroup.run(ActivityNodeActivationList))) && target(activation) && args(tokens);
	
	/**
	 * Prevents the call of the method ActivityNodeActivation.fire(TokenList)
	 * for an initial enabled node and adds it to the enabled activity nodes instead 
	 * @param activation Activation object of the initial enabled activity node
	 * @param tokens Tokens which are the parameters for the fire(TokenList) method
	 */
	void around(ActivityNodeActivation activation, TokenList tokens) : debugActivityNodeFiresInitialEnabledNodes(activation, tokens) {
		if(activation instanceof ActivityParameterNodeActivation){
			proceed(activation, tokens);
		} else {
			addEnabledActivityNodeActivation(0, activation, tokens);
		}
	}
	
	private void addEnabledActivityNodeActivation(int position, ActivityNodeActivation activation, TokenList tokens) {
		ActivityExecution currentActivityExecution = activation.getActivityExecution();	
				
		ExecutionStatus exestatus = ExecutionContext.getInstance().getActivityExecutionStatus(currentActivityExecution);
		
		List<ActivityNode> enabledNodes = exestatus.getEnabledNodes();				
		enabledNodes.add(activation.node);
		
		HashMap<ActivityNode, ActivityNodeActivation> enabledActivations = exestatus.getEnalbedActivations();
		enabledActivations.put(activation.node, activation);
		
		HashMap<ActivityNodeActivation, TokenList> enabledActivationTokens  = exestatus.getEnabledActivationTokens();
		enabledActivationTokens.put(activation, tokens);
		
		if(activation instanceof ActionActivation) {
			((ActionActivation)activation).firing = false;
		}
		
		exestatus.getEnabledNodesSinceLastStep().add(activation.node);
	}

	private void handleSuspension(ActivityExecution execution, Element location) {
		
		boolean isResume = ExecutionContext.getInstance().isExecutionInResumeMode(execution);
		
		ExecutionStatus executionstatus = ExecutionContext.getInstance().getActivityExecutionStatus(execution);
		
		ActivityEntryEvent callerevent = executionstatus.getActivityEntryEvent();		
		
		List<ActivityNode> allEnabledNodes = ExecutionContext.getInstance().getEnabledNodes(execution.hashCode());
		
		List<ActivityNode> enabledNodesSinceLastStepForExecution = executionstatus.getEnabledNodesSinceLastStep();
		for(int i=0; i<enabledNodesSinceLastStepForExecution.size();++i) {
			if(!allEnabledNodes.contains(enabledNodesSinceLastStepForExecution.get(i))) {
				enabledNodesSinceLastStepForExecution.remove(i);
				--i;
			}
		}
		
		List<Breakpoint> hitBreakpoints = new ArrayList<Breakpoint>();
		for(int i=0;i<enabledNodesSinceLastStepForExecution.size();++i) {
			ActivityNode node = enabledNodesSinceLastStepForExecution.get(i);
			Breakpoint breakpoint = ExecutionContext.getInstance().getBreakpoint(node);
			if(breakpoint != null) {
				hitBreakpoints.add(breakpoint);				
			}
		}
				
		SuspendEvent event = null;		
		if(hitBreakpoints.size() > 0) {
			event = new BreakpointEventImpl(execution.hashCode(), location, callerevent);
			((BreakpointEvent)event).getBreakpoints().addAll(hitBreakpoints);
			ExecutionContext.getInstance().setExecutionInResumeMode(execution, false);
		} else {
			if(!isResume) {
				event = new SuspendEventImpl(execution.hashCode(), location, callerevent);
			}
		}
		
		if(event != null) {
			event.getNewEnabledNodes().addAll(enabledNodesSinceLastStepForExecution);
			eventprovider.notifyEventListener(event);	
			enabledNodesSinceLastStepForExecution.clear();
		}
	}
	
	/**
	 * Call of ActivityNodeActivation.fire(TokenList) within ActivityNodeActivation.receiveOffer()
	 * which does not happen in the execution flow of ActivityNodeActivationGroup.run(ActivityNodeActivationList)
	 * i.e., call of ActivityNodeActivation.fire(TokenList) of all ActivityNodes other than initial enabled nodes
	 * @param activation Activation object of the ActivityNode for which fire(TokenList) is called
	 * @param tokens Tokens that are the parameter of fire(TokenList)
	 */
	private pointcut debugActivityNodeFiresOtherThanInitialEnabledNodes(ActivityNodeActivation activation, TokenList tokens) : call (void ActivityNodeActivation.fire(TokenList)) && withincode(void ActivityNodeActivation.receiveOffer()) && !(cflow(execution(void ActivityNodeActivationGroup.run(ActivityNodeActivationList)))) && target(activation) && args(tokens);
	
	/**
	 * Prevents the call of the method ActivityNodeActivation.fire(TokenList)
	 * and adds it to enabled activity node list instead
	 * @param activation ActivityNodeActivation object for which fire(TokenList) is called
	 * @param tokens Tokens that are the parameter of fire(TokenList)
	 */
	void around(ActivityNodeActivation activation, TokenList tokens) : debugActivityNodeFiresOtherThanInitialEnabledNodes(activation, tokens) {			
		if(activation.node == null) {
			//anonymous fork
			proceed(activation, tokens);
			return;
		}
				
		if(activation instanceof ObjectNodeActivation) {
			proceed(activation, tokens);
			return;
		}
		
		if(tokens.size() > 0) {
			addEnabledActivityNodeActivation(0, activation, tokens);
		} else {
			if(activation instanceof DecisionNodeActivation) {
				/*
				 * If a decision input flow is provided for a decision node
				 * and this decision node has no other incoming edge
				 * no tokens are provided
				 */
				addEnabledActivityNodeActivation(0, activation, tokens);
			}
		}
	}
	
	
	/**
	 * Execution of ActivityNodeActivation.fire(TokenList)
	 * @param activation Activation object for which fire(TokenList) is called
	 */
	private pointcut debugActivityNodeFiresExecution(ActivityNodeActivation activation) : execution (void ActivityNodeActivation.fire(TokenList)) && target(activation);
	
	/**
	 * Handling of SuspendEvent for ActivityNodes
	 * @param activation Activation object for the ActivityNode
	 */
	after(ActivityNodeActivation activation) :  debugActivityNodeFiresExecution(activation) {				
		if(activation.node == null) {
			// anonymous fork
			return;
		}
		if(activation instanceof ObjectNodeActivation) {
			return;
		}
		if(activation.getActivityExecution().getTypes().size() == 0){
			// Activity was already destroyed, i.e., the Activity already finished
			// This can happen in the case of existing breakpoints in resume mode				
			return;
		}
		boolean hasEnabledNodes = ExecutionContext.getInstance().hasEnabledNodesIncludingCallees(activation.getActivityExecution());
		if(!hasEnabledNodes) {
			handleEndOfActivityExecution(activation.getActivityExecution());
		} else {	
			if(activation instanceof CallActionActivation) {
				if(((CallActionActivation)activation).callExecutions.size() > 0) {
					return;
				}
			}
			handleSuspension(activation.getActivityExecution(), activation.node);
		}		
	}
	
	/**
	 * Execution of ActionActivation.sendOffers() in the execution context of ActionActivation.fire(TokenList)
	 * @param activation Activation object for which sendOffers() is called
	 */
	private pointcut debugFireActionActivationSendOffers(ActionActivation activation) : execution(void ActionActivation.sendOffers()) && target(activation) && cflow (execution(void ActionActivation.fire(TokenList)));
	
	/**
	 * Handles the do-while loop in the method ActionActivation.fire(TokenList)
	 * (is fireAgain)
	 * If the ActionActivation can fire again it is added to the enabled activity node list
	 * and because the token offers are consumed using the activation.takeOfferedTokens() method,
	 * the activation.fire(TokenList) method does not execute the action's behavior again
	 * @param activation
	 */
	after(ActionActivation activation) : debugFireActionActivationSendOffers(activation) {
		SemanticVisitor._beginIsolation();
		boolean fireAgain = false;
		activation.firing = false;
		TokenList incomingTokens = null;
		if (activation.isReady()) {
			incomingTokens = activation.takeOfferedTokens();
			fireAgain = incomingTokens.size() > 0;
			activation.firing = activation.isFiring() & fireAgain;
		}
		SemanticVisitor._endIsolation();
		
		if(fireAgain) {
			addEnabledActivityNodeActivation(0, activation, incomingTokens);
		}		
	}

	/**
	 * Call of ActivityNodeActivationGroup.run(ActivityNodeActivationList)
	 */
	private pointcut activityActivationGroupRun(ActivityNodeActivationGroup activationgroup) : call (void ActivityNodeActivationGroup.run(ActivityNodeActivationList)) && target(activationgroup);
	
	/**
	 * Handling of first SuspendEvent 
	 * First step is the step were the activity execution started and 
	 * the initial enabled nodes are determined.
	 */
	after(ActivityNodeActivationGroup activationgroup) : activityActivationGroupRun(activationgroup) {
		ExecutionStatus executionstatus = ExecutionContext.getInstance().getActivityExecutionStatus(activationgroup.activityExecution);
		
		if(executionstatus.getEnabledNodes().size() == 0) {
			return;
		}
		Activity activity = (Activity)activationgroup.activityExecution.types.get(0);		
		
		handleSuspension(activationgroup.activityExecution, activity);		
	}
	
	/**
	 * Execution of ActivityNodeActivationList.addValue(*) in the execution flow of 
	 * ActivityNodeActivationGroup.run(ActivityNodeActivationList)
	 * @param list ActivityNodeActivationList for which addValue(*) is called
	 */
	private pointcut valueAddedToActivityNodeActivationList(ActivityNodeActivationList list, ActivityNodeActivationGroup activationgroup) : execution (void ActivityNodeActivationList.addValue(*))  && target(list) && cflow (execution(void ActivityNodeActivationGroup.run(ActivityNodeActivationList)) && target(activationgroup));		
	
	/**
	 * Execution of Execution.execute()
	 * @param execution Execution object for which execute() is called 
	 */
	private pointcut activityExecutionExecuteExecution(ActivityExecution execution) : execution (void Execution.execute()) && target(execution);
	
	/**
	 * If there are no initial enabled nodes in the activity a ActivityExitEvent is produced
	 * @param behavior Behavior which has no initial enabled nodes 
	 */
	after(ActivityExecution execution) : activityExecutionExecuteExecution(execution) {
		ExecutionStatus executionStatus = ExecutionContext.getInstance().getActivityExecutionStatus(execution);
		
		if(executionStatus != null && executionStatus.getEnabledNodes().size() == 0 ) {
			handleEndOfActivityExecution(execution);
		}
	}
		
	private pointcut callActivityExecutionExecute(ActivityExecution execution, CallActionActivation activation) : call(void Execution.execute()) && withincode(void CallActionActivation.doAction()) && target(execution) && this(activation);
	
	before(ActivityExecution execution, CallActionActivation activation) : callActivityExecutionExecute(execution, activation) {
		ExecutionStatus executionStatus = ExecutionContext.getInstance().getActivityExecutionStatus(activation.getActivityExecution());
		
		ActivityNodeEntryEvent callaentryevent = executionStatus.getActivityNodeEntryEvent(activation.node);
		
		handleNewActivityExecution(execution, activation, callaentryevent);		
	}

	private void handleNewActivityExecution(ActivityExecution execution, ActivityNodeActivation caller, Event parent) {						
		ExecutionContext context = ExecutionContext.getInstance();
		
		Activity activity = (Activity) (execution.getBehavior());
		ActivityEntryEvent event = new ActivityEntryEventImpl(execution.hashCode(), activity, parent);		
		
		context.addActivityExecution(execution, caller, event);
		
		eventprovider.notifyEventListener(event);
	}	
	
	private void handleEndOfActivityExecution(ActivityExecution execution) {
		ExecutionStatus executionstatus = ExecutionContext.getInstance().getActivityExecutionStatus(execution);
		
		Activity activity = (Activity) (execution.getBehavior());
		ActivityEntryEvent entryevent = executionstatus.getActivityEntryEvent();
		ActivityExitEvent event = new ActivityExitEventImpl(execution.hashCode(), activity, entryevent);		
		
		{
			// Produce the output of activity
			// DUPLICATE CODE from void ActivityExecution.execute()
			ActivityParameterNodeActivationList outputActivations = execution.activationGroup.getOutputParameterNodeActivations();
			for (int i = 0; i < outputActivations.size(); i++) {
				ActivityParameterNodeActivation outputActivation = outputActivations.getValue(i);

				ParameterValue parameterValue = new ParameterValue();
				parameterValue.parameter = ((ActivityParameterNode) (outputActivation.node)).parameter;

				TokenList tokens = outputActivation.getTokens();
				for (int j = 0; j < tokens.size(); j++) {
					Token token = tokens.getValue(j);
					Value value = ((ObjectToken) token).value;
					if (value != null) {
						parameterValue.values.addValue(value);
						Debug.println("[event] Output activity=" + activity.name
								+ " parameter=" + parameterValue.parameter.name
								+ " value=" + value);
					}
				}

				execution.setParameterValue(parameterValue);
			}
		}
		
		// Add output to trace
		Trace trace = ExecutionContext.getInstance().getTrace(execution.hashCode());
		org.modelexecution.fumldebug.core.trace.tracemodel.ActivityExecution activityExecutionTrace = trace.getActivityExecutionByID(execution.hashCode());
		ActivityParameterNodeActivationList outputActivations = execution.activationGroup.getOutputParameterNodeActivations();
		for (int i = 0; i < outputActivations.size(); i++) {						
			ActivityParameterNodeActivation outputActivation = outputActivations.getValue(i);
			ActivityParameterNode parameternode = (ActivityParameterNode) (outputActivation.node); 
			Parameter parameter = parameternode.parameter;
			
			ParameterOutput parameterOutput = new ParameterOutputImpl();
			parameterOutput.setOutputParameterNode(parameternode);
			
			ParameterValue parameterValue = execution.getParameterValue(parameter);			
			ValueList parameterValues = parameterValue.values;
			for(int j=0;j<parameterValues.size();++j) {
				Value value = parameterValues.get(j);
				
				ObjectTokenInstance objectTokenInstance = new ObjectTokenInstanceImpl();
				ValueInstance valueInstance = new ValueInstanceImpl();
				valueInstance.setValue(value.copy());
				objectTokenInstance.setValue(valueInstance);
				
				parameterOutput.getParameterOutputTokens().add(objectTokenInstance);
			}
			activityExecutionTrace.getParameterOutputs().add(parameterOutput);
		}
		
		
		ActivityNodeActivation caller = executionstatus.getActivityCall();
		if(caller instanceof CallActionActivation) {				
			// Get the output from the called activity
			// DUPLICATE CODE from void CallActionActivation.doAction()
			ParameterValueList outputParameterValues = execution.getOutputParameterValues();
			for (int j = 0; j < outputParameterValues.size(); j++) {
				ParameterValue outputParameterValue = outputParameterValues.getValue(j);
				OutputPin resultPin = ((CallAction)caller.node).result.getValue(j);
				((CallActionActivation)caller).putTokens(resultPin, outputParameterValue.values);
			}
			
			// Destroy execution of the called activity
			execution.destroy();
			((CallActionActivation)caller).removeCallExecution(execution);
									
			// Notify about ActivityExitEvent
			eventprovider.notifyEventListener(event);
			
			// Notify about Exit of CallAction
			handleActivityNodeExit(caller);
			
			// Call sendOffer() from the CallAction
			((CallActionActivation) caller).sendOffers();
			
			// Check if can fire again
			((CallActionActivation) caller).firing = false;
			if(caller.isReady()) {
				TokenList incomingTokens = caller.takeOfferedTokens();
				if(incomingTokens.size() > 0) {
					addEnabledActivityNodeActivation(0, caller, new TokenList());
				}				
			}
					
			boolean hasCallerEnabledNodes = ExecutionContext.getInstance().hasCallerEnabledNodes(execution);
			
			if(!hasCallerEnabledNodes) {
				handleEndOfActivityExecution(caller.getActivityExecution());
			} else {
				handleSuspension(caller.getActivityExecution(), caller.node);
			}
			return;
		} else {			
			// ActivityExecution was triggered by user, i.e., ExecutionContext.debug() was called
			ParameterValueList outputValues = execution.getOutputParameterValues();
			ExecutionContext.getInstance().setActivityExecutionOutput(execution, outputValues);
			execution.destroy();
			eventprovider.notifyEventListener(event);
						
			this.eventlist.clear();
			
			ExecutionContext.getInstance().setExecutionInResumeMode(execution, false);
			 
			ExecutionContext.getInstance().removeActivityExecution(execution);
		}
	}		
	
	private void handleActivityNodeEntry(ActivityNodeActivation activation) {
		ExecutionStatus executionstatus = ExecutionContext.getInstance().getActivityExecutionStatus(activation.getActivityExecution());
		
		ActivityEntryEvent activityentry = executionstatus.getActivityEntryEvent();		
		ActivityNodeEntryEvent event = new ActivityNodeEntryEventImpl(activation.getActivityExecution().hashCode(), activation.node, activityentry);
		executionstatus.setActivityNodeEntryEvent(activation.node, event);
		eventprovider.notifyEventListener(event);
	}

	private void handleActivityNodeExit(ActivityNodeActivation activation) {
		ExecutionStatus executionstatus = ExecutionContext.getInstance().getActivityExecutionStatus(activation.getActivityExecution());
				
		ActivityNodeEntryEvent entry = executionstatus.getActivityNodeEntryEvent(activation.node);
		ActivityNodeExitEvent event = new ActivityNodeExitEventImpl(activation.getActivityExecution().hashCode(), activation.node, entry);
		eventprovider.notifyEventListener(event);
	}
	
	/**
	 * New extensional value at locus
	 */
	private pointcut locusNewExtensionalValue(ExtensionalValue value) : call (void Locus.add(ExtensionalValue)) && args(value) && !(cflow(execution(Value Value.copy())));
	
	after(ExtensionalValue value) : locusNewExtensionalValue(value) {
		if(value.getClass() == Object_.class || value.getClass() == Link.class) {
			ExtensionalValueEvent event = new ExtensionalValueEventImpl(value, ExtensionalValueEventType.CREATION);
			eventprovider.notifyEventListener(event);
		}
	}
	
	/**
	 * Extensional value removed from locus
	 */
	private pointcut locusExtensionalValueRemoved() : call (ExtensionalValue ExtensionalValueList.remove(int)) && withincode(void Locus.remove(ExtensionalValue));
	
	after() returning (Object obj) : locusExtensionalValueRemoved() {				
		if(obj.getClass() == Object_.class || obj.getClass() == Link.class) {
			ExtensionalValue value = (ExtensionalValue)obj;
			ExtensionalValueEvent event = new ExtensionalValueEventImpl(value, ExtensionalValueEventType.DESTRUCTION);
			eventprovider.notifyEventListener(event);
		}
	}
	
	/**
	 * Classifier removed/added as type of object
	 */
	private HashMap<ReclassifyObjectActionActivation, Object_> reclassifications = new HashMap<ReclassifyObjectActionActivation, Object_>();
	
	private pointcut reclassifyObjectAction(ReclassifyObjectActionActivation activation) : execution (void ReclassifyObjectActionActivation.doAction()) && target(activation);
	
	before(ReclassifyObjectActionActivation activation) : reclassifyObjectAction(activation) {
		if(activation.pinActivations.size()>0) {
			PinActivation pinactivation = activation.pinActivations.get(0);
			if(pinactivation.heldTokens.size()>0) {
				if(pinactivation.heldTokens.get(0) instanceof ObjectToken) {
					ObjectToken token = (ObjectToken)pinactivation.heldTokens.get(0);
					if(token.value instanceof Reference) {
						Reference ref = (Reference)token.value;
						Object_ obj = ref.referent;
						if(obj!= null) {
							reclassifications.put(activation, obj);
						}
					}
				}				
			}
		}
	}
	
	after(ReclassifyObjectActionActivation activation) : reclassifyObjectAction(activation) {
		reclassifications.remove(activation);
	}
	
	private pointcut classifierRemovedAsObjectType(ReclassifyObjectActionActivation activation) : call (void Class_List.removeValue(int)) && this(activation) && withincode(void ActionActivation.doAction());

	after(ReclassifyObjectActionActivation activation) : classifierRemovedAsObjectType(activation) {
		Object_ o = reclassifications.get(activation);
		ExtensionalValueEvent event = new ExtensionalValueEventImpl(o, ExtensionalValueEventType.TYPE_REMOVED);
		eventprovider.notifyEventListener(event);
	}
	
	private pointcut classifierAddedAsObjectType(ReclassifyObjectActionActivation activation) : call (void Class_List.addValue(Class_)) && this(activation) && withincode(void ActionActivation.doAction());

	after(ReclassifyObjectActionActivation activation) : classifierAddedAsObjectType(activation) {
		Object_ o = reclassifications.get(activation);
		ExtensionalValueEvent event = new ExtensionalValueEventImpl(o, ExtensionalValueEventType.TYPE_ADDED);
		eventprovider.notifyEventListener(event);
	}
	
	/**
	 * Feature values removed from object
	 */

	private pointcut compoundValueRemoveFeatureValue(Object_ o) : call(FeatureValue FeatureValueList.remove(int)) && this(o);
	
	after(Object_ o) returning(Object value): compoundValueRemoveFeatureValue(o) {				
		FeatureValueEvent event = new FeatureValueEventImpl(o, ExtensionalValueEventType.VALUE_DESTRUCTION, (FeatureValue)value);
		eventprovider.notifyEventListener(event);
	}
	
	/**
	 * Feature values added to object
	 */
	
	private pointcut compoundValueAddFeatureValue(Object_ o, FeatureValue value) : call(void FeatureValueList.addValue(FeatureValue)) && this(o) && args(value) && !cflow(execution(Object_ Locus.instantiate(Class_))) && !(cflow(execution(Value Value.copy())));
	
	after(Object_ o, FeatureValue value) : compoundValueAddFeatureValue(o, value) {				
		FeatureValueEvent event = new FeatureValueEventImpl(o, ExtensionalValueEventType.VALUE_CREATION, value);
		eventprovider.notifyEventListener(event);
	}
	
	/**
	 * Value of feature value set
	 */
	
	private pointcut featureValueSetValue(Object_ obj, FeatureValue value, ValueList values) : set(public ValueList FeatureValue.values) && this(obj) && target(value) && args(values) && withincode(void CompoundValue.setFeatureValue(StructuralFeature, ValueList, int)) && !cflow(execution(Object_ Locus.instantiate(Class_))) && !(cflow(execution(void ReclassifyObjectActionActivation.doAction()))) && !(cflow(execution(Value Value.copy())));	
	
	after(Object_ obj, FeatureValue value, ValueList values) : featureValueSetValue(obj, value, values) {
		FeatureValueEvent event = new FeatureValueEventImpl(obj, ExtensionalValueEventType.VALUE_CHANGED, value);
		eventprovider.notifyEventListener(event);
	}
	
	private HashMap<StructuralFeatureActionActivation, Object_> structfeaturevalueactions = new HashMap<StructuralFeatureActionActivation, Object_>();
	
	private pointcut structuralFeatureValueAction(StructuralFeatureActionActivation activation) : execution (void StructuralFeatureActionActivation.doAction()) && target(activation) && if(!(activation instanceof ReadStructuralFeatureActionActivation));
	
	before(StructuralFeatureActionActivation activation) : structuralFeatureValueAction(activation) {
		PinActivation pinactivation = activation.getPinActivation(((StructuralFeatureAction)activation.node).object);
		if(pinactivation != null) {
			if(pinactivation.heldTokens.size()>0) {
				if(pinactivation.heldTokens.get(0) instanceof ObjectToken) {
					ObjectToken token = (ObjectToken)pinactivation.heldTokens.get(0);
					Object_ obj = null;
					if(token.value instanceof Reference) {
						Reference ref = (Reference)token.value;
						obj = ref.referent;						
					} else if(token.value instanceof Object_) {
						obj = (Object_)token.value;
					}
					
					if(obj!= null) {
						structfeaturevalueactions.put(activation, obj);
					}
				}				
			}
		}
	}
	
	after(StructuralFeatureActionActivation activation) : structuralFeatureValueAction(activation) {
		structfeaturevalueactions.remove(activation);
	}

	private pointcut valueAddedToFeatureValue(AddStructuralFeatureValueActionActivation activation) : (call (void ValueList.addValue(Value)) || call (void ValueList.addValue(int, Value)) ) && this(activation) && withincode(void ActionActivation.doAction()) && !(cflow(execution(Value Value.copy())));

	after(AddStructuralFeatureValueActionActivation activation) : valueAddedToFeatureValue(activation) {
		handleFeatureValueChangedEvent(activation);
	}
	
	private pointcut valueRemovedFromFeatureValue(RemoveStructuralFeatureValueActionActivation activation) : call (Value ValueList.remove(int)) && this(activation) && withincode(void ActionActivation.doAction());

	after(RemoveStructuralFeatureValueActionActivation activation) : valueRemovedFromFeatureValue(activation) {
		handleFeatureValueChangedEvent(activation);
	}
	
	private void handleFeatureValueChangedEvent(StructuralFeatureActionActivation activation) {
		Object_ o = structfeaturevalueactions.get(activation);
		FeatureValue featureValue = o.getFeatureValue(((StructuralFeatureAction)activation.node).structuralFeature);
		if(featureValue.feature instanceof Property) {
			Property p = (Property)featureValue.feature;
			if(p.association != null) {
				return;
			}
		}
		
		FeatureValueEvent event = new FeatureValueEventImpl(o, ExtensionalValueEventType.VALUE_CHANGED, featureValue);
		eventprovider.notifyEventListener(event);
	}

	private pointcut tokenAddedToActivityParameterNodeAsUserInput(ActivityParameterNodeActivation activation, Token token) : call (void ObjectNodeActivation.addToken(Token)) && this(activation) && withincode(void ActivityParameterNodeActivation.fire(TokenList)) && args(token) && cflow(execution(void ActivityNodeActivationGroup.run(ActivityNodeActivationList))) && ( cflow(execution(void ExecutionContext.executeStepwise(Behavior, Object_, ParameterValueList))) || cflow(execution(void ExecutionContext.execute(Behavior, Object_, ParameterValueList))));
	
	/**
	 * Handels the user input for an activity execution
	 */
	before(ActivityParameterNodeActivation activation, Token token) : tokenAddedToActivityParameterNodeAsUserInput(activation, token) {
		ActivityParameterNode parameterNode = (ActivityParameterNode)activation.node;
		ActivityExecution execution = activation.getActivityExecution(); 
		int executionID = execution.hashCode();
		Trace trace = ExecutionContext.getInstance().getTrace(executionID);
		org.modelexecution.fumldebug.core.trace.tracemodel.ActivityExecution activityexecution = trace.getActivityExecutionByID(executionID);
		
		ParameterInput parameterInput = null;
		for(int i=0;i<activityexecution.getParameterInputs().size();++i) {
			if(activityexecution.getParameterInputs().get(i).getInputParameterNode().equals(parameterNode)){
				parameterInput = activityexecution.getParameterInputs().get(i);
				break;
			}
		}
		if(parameterInput == null) {
			parameterInput = new UserParameterInputImpl();
			parameterInput.setInputParameterNode(parameterNode);
			activityexecution.getParameterInputs().add(parameterInput);
		}
		
		ObjectTokenInstance tokenInstance = new ObjectTokenInstanceImpl();
		ValueInstance valueInstance = new ValueInstanceImpl();
		Value value = token.getValue().copy();
		valueInstance.setValue(value);
		tokenInstance.setValue(valueInstance);
		parameterInput.getParameterInputTokens().add(tokenInstance);
	}
	
	private pointcut valueAddedToLocusBecauseOfCopy() : call (void Locus.add(fUML.Semantics.Classes.Kernel.ExtensionalValue)) && withincode(Value ExtensionalValue.copy());
	
	/**
	 * Prevent addition of copied value to locus
	 */
	void around() : valueAddedToLocusBecauseOfCopy() {
	}
}