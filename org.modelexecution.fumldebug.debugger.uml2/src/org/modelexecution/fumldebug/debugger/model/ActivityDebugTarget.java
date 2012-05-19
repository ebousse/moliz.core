/*
 * Copyright (c) 2012 Vienna University of Technology.
 * All rights reserved. This program and the accompanying materials are made 
 * available under the terms of the Eclipse Public License v1.0 which accompanies 
 * this distribution, and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Philip Langer - initial API and implementation
 */
package org.modelexecution.fumldebug.debugger.model;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IMarkerDelta;
import org.eclipse.core.runtime.Assert;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.model.IBreakpoint;
import org.eclipse.debug.core.model.IDebugTarget;
import org.eclipse.debug.core.model.IMemoryBlock;
import org.eclipse.debug.core.model.IProcess;
import org.eclipse.debug.core.model.IStep;
import org.eclipse.debug.core.model.IThread;
import org.modelexecution.fumldebug.core.event.ActivityExitEvent;
import org.modelexecution.fumldebug.core.event.Event;
import org.modelexecution.fumldebug.core.event.StepEvent;
import org.modelexecution.fumldebug.debugger.FUMLDebuggerPlugin;
import org.modelexecution.fumldebug.debugger.process.ActivityProcess;

import fUML.Syntax.Activities.IntermediateActivities.ActivityNode;

public class ActivityDebugTarget extends ActivityDebugElement implements
		IDebugTarget, IStep { // , IBreakpointManagerListener {

	private ILaunch launch;
	private ActivityProcess process;
	private List<ActivityNodeThread> threads = new ArrayList<ActivityNodeThread>();

	private int rootExecutionId = -1;

	public ActivityDebugTarget(ILaunch launch, IProcess process) {
		super(null);
		Assert.isTrue(process instanceof ActivityProcess,
				"Process must be of type ActivityProcess");
		this.launch = launch;
		this.process = (ActivityProcess) process;
		this.process.addEventListener(this);
		processMissedEvents();
	}

	@Override
	public IDebugTarget getDebugTarget() {
		return this;
	}

	@Override
	public ILaunch getLaunch() {
		return launch;
	}

	@Override
	public void notify(Event event) {
		if (isStepEvent(event) && threads.isEmpty()) {
			setRootExecutionId((StepEvent) event);
			initializeThreads((StepEvent) event);
		} else if (isFinalActivityExitEvent(event)) {
			doTermination();
		}
	}

	private boolean isStepEvent(Event event) {
		return event instanceof StepEvent;
	}

	private void setRootExecutionId(StepEvent event) {
		rootExecutionId = event.getActivityExecutionID();
	}

	private void initializeThreads(StepEvent event) {
		for (ActivityNode activityNode : event.getNewEnabledNodes()) {
			addThread(activityNode, event.getActivityExecutionID());
		}
		fireContentChangeEvent();
	}

	private ActivityNodeThread createNewThread(ActivityNode activityNode,
			int executionId) {
		return new ActivityNodeThread(this, activityNode, executionId);
	}

	protected void addThreads(List<ActivityNode> newEnabledNodes,
			int executionId) {
		for (ActivityNode activityNode : newEnabledNodes) {
			addThread(activityNode, executionId);
		}
		fireContentChangeEvent();
	}

	private void addThread(ActivityNode activityNode, int executionId) {
		ActivityNodeThread newThread = createNewThread(activityNode,
				executionId);
		threads.add(newThread);
	}

	private boolean isFinalActivityExitEvent(Event event) {
		if (event instanceof ActivityExitEvent) {
			ActivityExitEvent activityExitEvent = (ActivityExitEvent) event;
			return rootExecutionId == activityExitEvent
					.getActivityExecutionID();
		}
		return false;
	}

	private void doTermination() {
		try {
			terminate();
		} catch (DebugException e) {
			FUMLDebuggerPlugin.log(e);
		}
	}

	@Override
	public boolean canTerminate() {
		return process.canTerminate();
	}

	@Override
	public boolean isTerminated() {
		return process.isTerminated();
	}

	@Override
	public void terminate() throws DebugException {
		process.terminate();
		process.removeEventListener(this);
		terminateThreads();
		fireTerminateEvent();
	}

	private void terminateThreads() throws DebugException {
		for (ActivityNodeThread thread : new ArrayList<ActivityNodeThread>(
				threads)) {
			thread.terminate();
			removeThread(thread);
		}
	}

	protected void removeThread(ActivityNodeThread thread) {
		threads.remove(thread);
	}

	@Override
	public boolean canResume() {
		return !isTerminated() && isSuspended();
	}

	@Override
	public boolean canSuspend() {
		return !isTerminated() && !isSuspended();
	}

	@Override
	public boolean isSuspended() {
		return !isTerminated() && isStarted();
	}

	public boolean isStarted() {
		return process.isStarted();
	}

	@Override
	public void resume() throws DebugException {
		process.resume();
	}

	@Override
	public void suspend() throws DebugException {
		process.suspend();
	}

	@Override
	public boolean canDisconnect() {
		return false;
	}

	@Override
	public void disconnect() throws DebugException {
		process = null;
	}

	@Override
	public boolean isDisconnected() {
		return process == null;
	}

	@Override
	public boolean supportsStorageRetrieval() {
		return false;
	}

	@Override
	public IMemoryBlock getMemoryBlock(long startAddress, long length)
			throws DebugException {
		return null;
	}

	@Override
	public void breakpointAdded(IBreakpoint breakpoint) {
		// TODO Auto-generated method stub

	}

	@Override
	public void breakpointRemoved(IBreakpoint breakpoint, IMarkerDelta delta) {
		// TODO Auto-generated method stub

	}

	@Override
	public void breakpointChanged(IBreakpoint breakpoint, IMarkerDelta delta) {
		// TODO Auto-generated method stub

	}

	@Override
	public boolean supportsBreakpoint(IBreakpoint breakpoint) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public IProcess getProcess() {
		return process;
	}

	@Override
	protected ActivityProcess getActivityProcess() {
		return process;
	}

	@Override
	public IThread[] getThreads() throws DebugException {
		return threads.toArray(new IThread[threads.size()]);
	}

	@Override
	public boolean hasThreads() throws DebugException {
		return !threads.isEmpty();
	}

	@Override
	public boolean canStepInto() {
		return getThreadThatCanStepInto() != null;
	}

	private ActivityNodeThread getThreadThatCanStepInto() {
		for (ActivityNodeThread thread : threads) {
			if (thread.canStepInto())
				return thread;
		}
		return null;
	}

	@Override
	public boolean canStepOver() {
		return getThreadThatCanStepOver() != null;
	}
	
	private ActivityNodeThread getThreadThatCanStepOver() {
		for (ActivityNodeThread thread : threads) {
			if (thread.canStepOver())
				return thread;
		}
		return null;
	}

	@Override
	public boolean canStepReturn() {
		return getThreadThatCanStepReturn() != null;
	}
	
	private ActivityNodeThread getThreadThatCanStepReturn() {
		for (ActivityNodeThread thread : threads) {
			if (thread.canStepReturn())
				return thread;
		}
		return null;
	}

	@Override
	public boolean isStepping() {
		return false;
	}

	@Override
	public void stepInto() throws DebugException {
		getThreadThatCanStepInto().stepInto();
	}

	@Override
	public void stepOver() throws DebugException {
		getThreadThatCanStepOver().stepOver();
	}

	@Override
	public void stepReturn() throws DebugException {
		getThreadThatCanStepReturn().stepReturn();
	}

	@Override
	public String getName() throws DebugException {
		return process.getName();
	}
}
