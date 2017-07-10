# eb-singularity                                                                
Stuff related to integrating [EasyBuild](https://github.com/easybuilders/easybuild) &amp; [Singularity](https://github.com/singularityware/singularity)
                                                                                
So far, this is just an experimental proof-of-concept for creating Singularity containers using [EasyBuild easyconfig files](https://github.com/easybuilders/easybuild-easyconfigs).
                                                                                
## Approach                                                                     
The basic idea is to give Singularity an easyconfig file that it will use to build a container. The approach taken here is to `create` and `bootstrap` a Singularity image in a directory that has one or more easyconfig files in it.  The [build.def](/build.def) file will look for any easyconfig file(s) that exist in the same directory and will copy them to the     container during the `%setup` portion of the `bootstrap`.  
                                                                                
## Instructions for use                                                         
Assuming you have Singularity installed on your system, you could use these steps to install [`ack`](https://beyondgrep.com/) into a container via the [`ack` easyconfig](https://github.com/easybuilders/easybuild-easyconfigs/blob/master/easybuild/easyconfigs/a/ack/ack-2.14.eb) 
                                                                                
First download the [easyconfig repo](https://github.com/easybuilders/easybuild-easyconfigs) and copy the `ack` easyconfig to a new directory.
```                                                                             
$ cd ~                                                                          
                                                                                
$ git clone https://github.com/easybuilders/easybuild-easyconfigs.git           
                                                                                
$ mkdir easybuild-test                                                          
                                                                                
$ cp easybuild-easyconfigs/easybuild/easyconfigs/a/ack/ack-2.14.eb easybuild-test/
```                                                                             
Then download this repo and copy the [build.def](/build.def) file into the directory you just created.
```                                                                             
$ git clone https://github.com/easybuilders/eb-singularity.git

$ cp eb-singularity/build.def easybuild-test/                                                                                                               
```
Now just build a container in that directory using the [build.def](/build.def) file.
```
$ cd easybuild-test

$ singularity create -s 2000 ack-2.14.img

$ sudo singularity bootstrap ack-2.14.img build.def
```
And your all set!
```
$ singularity shell ack-2.14.img

> source /etc/bashrc # hope to fix this bug soon

> module load which ack

> ack --bar
```

## To Do:
- Right now the `build.def` file downloads a starter container from Docker Hub and uses that to finish the installation.  We may want the `build.def` to be self-contained so that it installs EasyBuild and Lmod itself.  We may also want to start from a few different containers that already have compiler toolchains installed in them so that we don't have to begin all of our containers by compiling `gcc`.
- The way this sources the environment for Lmod is broken and needs to be fixed.
- The container should be stripped of all non-essential programs (including EasyBuild and Lmod) when it is finished installing the target application.  This will shrink the size so that we can copy the container contents to another slimmer container.  
- At the conclusion of the build, we should load the target app with Lmod using the `module` command and then take a snapshot of the environment.  Then the environment should be written out to the `/.singularity.d/env` directory so that we can remove Lmod and still access our app. 
- Right now the build is happening within the container.  But this is wrong.  Ideally, I think we want it in `/scratch` since `/tmp` can be small and may bottom out if we are building big things with tons of source code and object files (like `gcc`).  
