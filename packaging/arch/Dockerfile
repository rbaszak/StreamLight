FROM archlinux:base-devel
RUN pacman -Syu --noconfirm --needed qt6-base qt6-declarative qt6-svg qt6-wayland \
    sdl2-compat sdl2_ttf ffmpeg opus openssl libva libvdpau libdrm libplacebo \
    libx11 wayland libegl libglvnd vulkan-headers xorg-server-xvfb git && \
    useradd -m builder
WORKDIR /build
RUN pacman -S --noconfirm --needed xdotool
RUN chown builder:builder /build
USER builder
CMD ["bash", "/src/packaging/arch/build.sh"]
