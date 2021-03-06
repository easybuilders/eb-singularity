eb-singularity
---------------

This repo contains Singularity definition file generated by easybuild to build containers. The containers are built on `Sylabs Cloud <https://cloud.sylabs.io/>`_

Easybuild Base Container
-------------------------

There is a Singularity recipe for Easybuild Base contaienr for Centos 7 called `Singularity.Easybuild-CentOS-7 <https://github.com/shahzebsiddiqui/eb-singularity/blob/master/Singularity.Easybuild-CentOS-7>`_. 
The easybuild base container is meant to configure easybuild environment so we can build Singularity containers with easybuild. We can extend the
base container concept for other distributions

The easybuild base container can be fetched by running::

  singularity pull --arch amd64 library://shahzebmsiddiqui/default/easybuild:centos-7
  
Directory Structure Recommendation
-----------------------------------

The top-level ``proposal`` directory contains a few ways we can organize Singularity Recipe files. Once this is decided by the easybuild community we 
can enforce this when building the container library. 

Easybuild Singulariy Recipes
-----------------------------

The ``apps`` directory contains the Easybuild Singularity Recipe that were successfully built in Sylabs Cloud into containers. The recipe 
files were auto-generated by easybuild and tweaked manually afterwards.  

The easybuild container stack can be found at Sylabs at https://cloud.sylabs.io/library/shahzebmsiddiqui/easybuild-centos7 

Getting Started
----------------

You can pull one of the easybuild containers from Sylabs let's say ``java:1.8.0_92`` as follows::

  singularity pull --arch amd64 library://shahzebmsiddiqui/easybuild-centos7/java:1.8.0_92
  
Once we have the container locally we can shell into container and see the modules loaded::

  ssi29@ag-mxg-hulk090> singularity shell java-1.8.0_92.sif
  Singularity java-1.8.0_92.sif:~/gpfs/eb-images> module av

  -------------------------------- /app/modules/all ----------------------------------------
     Java/1.8.0_92 (L)

    Where:
     L:  Module is loaded

  Use "module spider" to find all possible modules and extensions.
  Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".


The java binary is accessible in the container ``$PATH`` so you can use this container to build your Java program such as a ``helloworld.java`` as follows::

  ssi29@ag-mxg-hulk090> singularity exec java-1.8.0_92.sif javac  helloworld.java
  ssi29@ag-mxg-hulk090> singularity exec java-1.8.0_92.sif java HelloWorld
  Hello, World


Few Important Points
---------------------

Currently, we don't have a central repository for building easybuild containers. Building a container registry on-prem using `Singularity Enterprise <https://sylabs.io/singularity-enterprise/>`_  would 
limit the open source community from contributing back. According to Sylabs, Singularity Enterprise is on-prem version of Sylabs Cloud.

When you build containers on Sylabs Cloud, you can only push containers to your library (i.e ``https://cloud.sylabs.io/library/shahzebmsiddiqui/``). This
prevents others from contributing because their is no concept of shared namespace for a library with Access Control List (ACLs) to control permission
on a library. I foresee easybuild maintainers have the following ACLs ``Push``, ``Update``, ``Delete`` on containers and everyone has ``Pull`` access
to all containers in a library.  



Contributing Back
-----------------

If you are interested in contributing back, fork the repo https://github.com/shahzebsiddiqui/eb-singularity and generate your recipe and issue a
PR and I will build and publish the container in my library at https://cloud.sylabs.io/library/shahzebmsiddiqui/easybuild-centos7  

You should build your containers using the base container provided in this repo, this means you should have the following line set in your 
recipe::

  Bootstrap: library
  From:  shahzebmsiddiqui/default/easybuild:centos-7


The quickest way to get started is copy one of the recipe files in ``apps``. To demonstrate we will try building ``M4-1.4.19`` by using one
of the existing recipes.

First navigate to your fork and go to the ``m4`` directory and copy the file as follows::

  cd apps/m/m4
  cp Singularity.M4-1.4.18 Singularity.M4-1.4.19


The format of the recipe file is ``Singularity.<easyconfig>`` without the ``.eb`` extension. Next we change the following lines

- ``eb M4-1.4.18.eb --robot`` --> ``eb M4-1.4.19.eb --robot``

- ``module load M4/1.4.18`` --> ``module load M4/1.4.19``

There will be some containers that can't be built on Sylabs either due to timeout (60min) or eb can't fetch source files (Java). In those
cases we need to build container locally and push it to Sylabs. For example, the ``java:1.8.0_92`` container found at https://cloud.sylabs.io/library/shahzebmsiddiqui/easybuild-centos7/java was 
built locally and pushed to Sylabs. 

Certainly there will be some applications that require additional dependencies to be installed in ``%post`` section, so ``copy-paste`` and build 
container won't work, you will need to work through the details and build container successfully before we can accept it.

Container Stacking
-------------------

When you are building containers, please reuse existing containers as a base image to satisfy all the dependency. For example ``ant-1.9.7-Java-1.8.0_92.eb`` has 
a dependency on ``Java-1.8.0.92.eb`` so we set the base image to the following::

  Bootstrap: library
  From:  shahzebmsiddiqui/easybuild-centos7/java:1.8.0_92

See recipe file for `Singularity.ant-1.9.7-Java-1.8.0_92 <https://github.com/shahzebsiddiqui/eb-singularity/blob/master/apps/a/ant/Singularity.ant-1.9.7-Java-1.8.0_92>`_ for
more details.

If you were to build ant with the easybuild base image we would end up building the entire dependency tree including Java-1.8.0_92. We can
confirm this by running a dry run ``-D`` to see all the modules built::

  $ eb ant-1.9.7-Java-1.8.0_92.eb -D
  == temporary log file in case of crash /scratch/eb-dYEUtq/easybuild-fC51To.log
  Dry run: printing build status of easyconfigs and dependencies
  CFGS=/mxg-hpc/users/ssi29/easybuild/software/EasyBuild/4.1.0/easybuild/easyconfigs
   * [ ] $CFGS/j/Java/Java-1.8.0_92.eb (module: Java/1.8.0_92)
   * [ ] $CFGS/j/JUnit/JUnit-4.12-Java-1.8.0_92.eb (module: JUnit/4.12-Java-1.8.0_92)
   * [ ] $CFGS/a/ant/ant-1.9.7-Java-1.8.0_92.eb (module: ant/1.9.7-Java-1.8.0_92)
  == Temporary log file(s) /scratch/eb-dYEUtq/easybuild-fC51To.log* have been removed.
  == Temporary directory /scratch/eb-dYEUtq has been removed.









