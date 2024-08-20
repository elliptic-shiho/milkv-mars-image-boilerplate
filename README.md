A minimum SD-card bootable image builder for Milk-V Mars (JH7110)
====================================================================

Minimum image creation boilerplate

## How to use
```
./build_stage1.sh
./build_image.sh
```

* `build_stage1.sh` builds u-boot / opensbi
* `build_image.sh` builds actual sd-card image

You need to modify `build_image.sh` to set actual filesystem structure. This repo's code will included only `vf2_uEnv.txt` into the filesystem. 

## License
My own code is released under the MIT license. other code is released under the each specified license.

`vf2_uEnv.txt` is borrowed from https://github.com/milkv-mars/mars-buildroot-sdk/blob/1fd6bac9f2efde47fbb8afd28d2903c49f893e3f/conf/vf2_uEnv.txt

`genimage.cfg` is borrowed from https://github.com/milkv-mars/mars-buildroot-sdk/blob/1fd6bac9f2efde47fbb8afd28d2903c49f893e3f/conf/genimage.cfg and I modified for three-partitioned structure. 
