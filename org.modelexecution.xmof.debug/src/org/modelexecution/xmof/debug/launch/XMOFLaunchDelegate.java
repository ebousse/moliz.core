/*
 * Copyright (c) 2012 Vienna University of Technology.
 * All rights reserved. This program and the accompanying materials are made 
 * available under the terms of the Eclipse Public License v1.0 which accompanies 
 * this distribution, and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Philip Langer - initial API and implementation
 */
package org.modelexecution.xmof.debug.launch;

import java.util.ArrayList;
import java.util.Collection;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.debug.core.DebugPlugin;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.debug.core.model.IProcess;
import org.eclipse.debug.core.model.LaunchConfigurationDelegate;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.modelexecution.xmof.configuration.ConfigurationObjectMap;
import org.modelexecution.xmof.debug.XMOFDebugPlugin;
import org.modelexecution.xmof.debug.internal.process.InternalXMOFProcess;
import org.modelexecution.xmof.debug.internal.process.InternalXMOFProcess.Mode;
import org.modelexecution.xmof.vm.XMOFBasedModel;

public class XMOFLaunchDelegate extends LaunchConfigurationDelegate {

	private static final String XMOF_EXEC_LABEL = "xMOF Execution Process";
	private ResourceSet resourceSet;

	@Override
	public void launch(ILaunchConfiguration configuration, String mode,
			ILaunch launch, IProgressMonitor monitor) throws CoreException {
		
		resourceSet = new ResourceSetImpl();

		XMOFBasedModel model = getXMOFBasedModel(configuration);
		InternalXMOFProcess xMOFProcess = new InternalXMOFProcess(model,
				getProcessMode(mode));
		IProcess process = DebugPlugin.newProcess(launch, xMOFProcess,
				XMOF_EXEC_LABEL);

		if (mode.equals(ILaunchManager.DEBUG_MODE)) {
			// TODO set debug target
			System.out.println("Should debug:" + process);
		}
	}

	private XMOFBasedModel getXMOFBasedModel(ILaunchConfiguration configuration)
			throws CoreException {

		Collection<EObject> inputModelElements = loadInputModelElements(configuration);

		if (useConfigurationMetamodel(configuration)) {
			String confMetamodelPath = getConfigurationMetamodelPath(configuration);
			Collection<EPackage> configurationPackages = loadConfigurationMetamodel(confMetamodelPath);
			ConfigurationObjectMap confMap = new ConfigurationObjectMap(
					inputModelElements, configurationPackages);
			return new XMOFBasedModel(confMap.getConfigurationObjects());
		} else {
			return new XMOFBasedModel(inputModelElements);
		}
	}

	private boolean useConfigurationMetamodel(ILaunchConfiguration configuration)
			throws CoreException {
		return configuration.getAttribute(
				XMOFDebugPlugin.ATT_USE_CONFIGURATION_METAMODEL, false);
	}

	private String getConfigurationMetamodelPath(
			ILaunchConfiguration configuration) throws CoreException {
		return configuration
				.getAttribute(XMOFDebugPlugin.ATT_CONFIGURATION_METAMODEL_PATH,
						(String) null);
	}

	private Collection<EPackage> loadConfigurationMetamodel(
			String confMetamodelPath) {
		Resource resource = loadResource(confMetamodelPath);
		Collection<EPackage> confMMPackages = new ArrayList<EPackage>();
		for (EObject eObject : resource.getContents()) {
			if (eObject instanceof EPackage) {
				confMMPackages.add((EPackage) eObject);
			}
		}
		return confMMPackages;
	}

	private Resource loadResource(String path) {
		return resourceSet.getResource(URI.createPlatformResourceURI(path, true), true);
	}

	private Collection<EObject> loadInputModelElements(
			ILaunchConfiguration configuration) throws CoreException {
		String modelPath = getModelPath(configuration);
		Collection<EObject> inputModelElements = getInputModelElements(modelPath);
		return inputModelElements;
	}

	private String getModelPath(ILaunchConfiguration configuration) throws CoreException {
		return configuration.getAttribute(XMOFDebugPlugin.ATT_MODEL_PATH,
				(String) null);
	}

	private Collection<EObject> getInputModelElements(String modelPath) {
		Resource resource = loadResource(modelPath);
		return resource.getContents();
	}

	private Mode getProcessMode(String mode) {
		if (mode.equals(ILaunchManager.DEBUG_MODE)) {
			return Mode.DEBUG;
		} else {
			return Mode.RUN;
		}
	}

	@Override
	public boolean buildForLaunch(ILaunchConfiguration configuration,
			String mode, IProgressMonitor monitor) throws CoreException {
		return false;
	}

}
