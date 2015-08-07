ifndef __SDSCDEVEL_COMMONROLLS_MK
__SDSCDEVEL_COMMONROLLS_MK = yes

# Makes ROLLDEF calls (see RollStack.mk) for all SDSC rolls that aren't
# specific to a particular cluster.  include this file after including
# RollStack.mk and after defining these make vars:
#
# * MULTI_COMPILER - list of compiler modules to be loaded by rolls that can be
#     built and rolled with more than one compiler
# * MULTI_MPI - list of mpi modules to be loaded by rolls that can be built and
#     rolled with more than one mpi flavor
# * %-ROLLOPTS - optional package-specific ROLLOPTS values

# Implicit roll prereqs, not derived from ROLL{COMPILER,MPI,PY}
abyss_PREREQS = boost
beast_PREREQS = beagle
biotools_PREREQS = boost cmake fftw gnucompiler hdf math
chemistry_PREREQS = cmake fftw
cilk_PREREQS = gnucompiler
cpmd_PREREQS = fftw
gaussian_PREREQS = pgi
geo_PREREQS = R
grace_PREREQS = fftw netcdf
gnutools_PREREQS = gnucompiler
guile_PREREQS = gnucompiler gnutools
jags_PREREQS = math R
math_PREREQS = cmake fftw gnucompiler hdf
mpi_PREREQS = gnutools
mrbayes_PREREQS = beagle
netcdf_PREREQS = hdf
octave_PREREQS = fftw hdf
openbabel_PREREQS = cmake
polymake_PREREQS = boost gnucompiler
r-modules_PREREQS = netcdf R
siesta_PREREQS = hdf netcdf
trilinos_PREREQS = cmake
vasp_PREREQS = fftw
vmd_PREREQS = cmake netcdf
vtk_PREREQS = cmake

# Complete roll set categorized by ROLLCOMPILER value...
DEFAULT_COMPILER_ROLLS = \
  abyss amber beagle beast biotools chemistry cipres cpmd gamess geo grace \
  jags migrate mpi4py mpiblast mrbayes nwchem octave performance phylobayes \
  polymake python qe R scipy siesta upc vasp vtk
MULTI_COMPILER_ROLLS = \
  atlas boost fftw fpmpi hdf math mpi netcdf trilinos
NO_COMPILER_ROLLS = \
  beast2 blcr cilk cmake data-transfer ddt fsa gaussian gnucompiler gnutools \
  guile hadoop idl intel molden mono nagios openbabel pgi r-modules \
  rapidminer raxml stata vmd weka

# ... and again by ROLLMPI value.
DEFAULT_MPI_ROLLS = \
  abyss amber biotools chemistry cpmd gamess grace migrate mpi4py mpiblast \
  mrbayes nwchem performance phylobayes qe r-modules siesta upc vasp vtk
MULTI_MPI_ROLLS = \
  boost fftw hdf math fpmpi netcdf trilinos
NO_MPI_ROLLS = \
  atlas beagle beast beast2 blcr cilk cipres cmake data-transfer ddt fsa \
  gaussian geo gnucompiler gnutools guile hadoop idl intel jags molden mono \
  mpi nagios octave openbabel polymake pgi python R rapidminer raxml scipy \
  stata vmd weka

# Rolls that support ROLLPY make var
PYTHON_ROLLS = hdf math mpi4py openbabel scipy trilinos vmd

ALL_ROLLS = $(sort $(DEFAULT_COMPILER_ROLLS) $(MULTI_COMPILER_ROLLS) $(NO_COMPILER_ROLLS))

# Rolls that are known to have build failures w/the pgi compilers.
NO_PGI_ROLLS = atlas boost trilinos

# Rolls not available from github, generally because of a paid license
RESTRICTED_ROLLS = amber ddt gaussian idl intel pgi stata vasp

# gmake's handling of line continuations makes it difficult to format call
# invocations readably.  Placing the call into a variable to be passed to eval
# is at least better than squishing everything onto a single line.
DEFINE_ALL_ROLLS = \
$$(foreach roll,$$(ALL_ROLLS), \
  $$(call ROLLDEF, \
          $$(roll), \
          $$(if $$(filter $$(roll),$$(MULTI_COMPILER_ROLLS)),ROLLCOMPILER=$$(MULTI_COMPILER)), \
          $$(if $$(filter $$(roll),$$(NO_PGI_ROLLS)),ROLLCOMPILER=$$(MULTI_COMPILER:pgi=)), \
          $$(if $$(filter $$(roll),$$(NO_COMPILER_ROLLS)),ROLLCOMPILER=), \
          $$(if $$(filter $$(roll),$$(MULTI_MPI_ROLLS)),ROLLMPI=$$(MULTI_MPI)), \
          $$(if $$(filter $$(roll),$$(NO_MPI_ROLLS)),ROLLMPI=), \
          $$(if $$(filter $$(roll),$$(PYTHON_ROLLS)),ROLLPY=python), \
          PREREQS=$$($$(roll)_PREREQS), \
          $$(if $$($$(roll)_ROLLOPTS),ROLLOPTS=$$($$(roll)_ROLLOPTS)), \
  ) \
)
comma := ,
empty :=
space := $(empty) $(empty)
$(eval $(subst $(comma)$(space),$(comma),$(DEFINE_ALL_ROLLS)))

# TODO: incorporate these rolls into above lists?
$(call ROLLDEF,matlab)
$(call ROLLDEF,mlnx-ofed)
$(call ROLLDEF,xsede-stats)

# TODO: Gordon only
# abaqus - source?
# dppdiv
# gnu - renamed gnutools
# jmodeltest2 - no github
# knime
# mopac(P) - abandoned
# mv2profile - no github
# p3dfft
# qchem(P)
# visit

# TODO: orphaned?
# boltztrap
# cern
# cgns
# columbus(P) - abandoned
# cuda - abandoned
# db2(P) - abandoned
# fsl
# git - no github
# img-storage - no github
# julia
# lfs(P)
# lustre(P)
# moab(P)
# ncl
# node - no github
# neuron
# perftest
# paraview
# rabbitmq
# rosetta
# seedme
# tecplot(P) - abandoned
# usetrax - abandoned
# wrf - no github
 
# Deprecated rolls
# dataform(D) - renamed netcdf
# garli(D) - merged into raxml
# gdal(D) - merged into geo
# geos(D) - merged into geo
# mkl(D) - merged into intel
# papi(D) - merged into performance
# plink(D) - merged into biotools
# proj(D) - merged into geo

endif # __SDSCDEVEL_COMMONROLLS_MK
